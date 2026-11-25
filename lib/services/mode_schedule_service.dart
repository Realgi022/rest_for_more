import 'dart:async';

import 'package:flutter/material.dart';

import '../models/mode_schedule.dart';
import '../models/mode_schedule_occurrence.dart';
import '../models/mode_task.dart';
import '../models/mode_task_presets.dart';
import '../data/repository/mode_schedule_repository.dart';
import '../data/repository/mode_task_completion_repository.dart';

final modeScheduleService = ModeScheduleService();

typedef ModeScheduleActivator = FutureOr<void> Function(
  ModeSchedule schedule,
  Duration remaining,
);

class ModeScheduleService extends ChangeNotifier {
  static const maxSchedulesPerMode = 10;
  static const maxTasksPerSchedule = 20;
  static const maxStoredOccurrences = 100;
  static const _runnerInterval = Duration(seconds: 30);

  final List<ModeSchedule> _schedules = [];
  final Map<ModeId, ModeScheduleActivator> _activators = {};
  final Map<String, String> _activatedWindowKeys = {};
  final List<ModeScheduleOccurrence> _occurrences = [];

  Timer? _runner;

  List<ModeSchedule> get schedules {
    return List.unmodifiable(_sortedSchedules(_schedules));
  }

  List<ModeSchedule> schedulesFor(ModeId modeId) {
    return _sortedSchedules(
      _schedules.where((schedule) => schedule.modeId == modeId).toList(),
    );
  }

  void registerActivator(ModeId modeId, ModeScheduleActivator activator) {
    _activators[modeId] = activator;
  }

  void startRunner() {
    _runner?.cancel();
    _checkSchedules();
    _runner = Timer.periodic(_runnerInterval, (_) => _checkSchedules());
  }

  void stopRunner() {
    _runner?.cancel();
    _runner = null;
  }

  Future<void> load() async {
    _schedules
      ..clear()
      ..addAll(
        (await ModeScheduleRepository.loadSchedules()).map(_withLegacyTasks),
      );
    _occurrences
      ..clear()
      ..addAll(
        (await ModeTaskCompletionRepository.load()).take(maxStoredOccurrences),
      );

    notifyListeners();
  }

  Future<bool> addSchedule({
    required ModeId modeId,
    required String name,
    required List<String> dates,
    required bool repeatWeekly,
    required List<int> weekdays,
    required int startTimeMinutes,
    required int endTimeMinutes,
    List<ModeTask>? tasks,
  }) async {
    if (schedulesFor(modeId).length >= maxSchedulesPerMode) return false;

    final schedule = ModeSchedule(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'Schedule' : name.trim(),
      modeId: modeId,
      dates: [...dates]..sort(),
      repeatWeekly: repeatWeekly,
      weekdays: [...weekdays]..sort(),
      startTimeMinutes: startTimeMinutes,
      endTimeMinutes: endTimeMinutes,
      enabled: true,
      tasks: _validatedTasks(tasks ?? presetsForMode(modeId)),
    );

    _schedules.add(schedule);
    await _save();
    return true;
  }

  Future<void> updateSchedule(ModeSchedule schedule) async {
    final index = _schedules.indexWhere((item) => item.id == schedule.id);

    if (index == -1) return;

    _schedules[index] = schedule.copyWith(
      tasks: _validatedTasks(schedule.tasks),
    );
    await _save();
  }

  Future<void> deleteSchedule(String id) async {
    _schedules.removeWhere((schedule) => schedule.id == id);
    await _save();
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final index = _schedules.indexWhere((schedule) => schedule.id == id);

    if (index == -1) return;

    _schedules[index] = _schedules[index].copyWith(enabled: enabled);
    await _save();
  }

  String occurrenceKey(ModeSchedule schedule, DateTime occurrenceStart) =>
      '${schedule.id}:${occurrenceStart.toIso8601String()}';

  String occurrenceKeyForDate(ModeSchedule schedule, DateTime date) =>
      occurrenceKey(
        schedule,
        DateTime(
          date.year,
          date.month,
          date.day,
          schedule.startTimeMinutes ~/ 60,
          schedule.startTimeMinutes % 60,
        ),
      );

  List<ModeScheduleOccurrence> get occurrences =>
      List.unmodifiable(_occurrences.reversed);

  ModeScheduleOccurrence? occurrenceFor(String occurrenceKey) {
    for (final occurrence in _occurrences) {
      if (occurrence.key == occurrenceKey) return occurrence;
    }
    return null;
  }

  Set<String> completedTasksFor(String occurrenceKey) => Set.unmodifiable(
    occurrenceFor(occurrenceKey)?.completedTaskIds ?? const <String>{},
  );

  Future<void> setTaskCompleted({
    required String occurrenceKey,
    required String taskId,
    required bool completed,
  }) async {
    final index = _occurrences.indexWhere((item) => item.key == occurrenceKey);
    if (index == -1) return;

    final occurrence = _occurrences[index];
    final tasks = {...occurrence.completedTaskIds};
    completed ? tasks.add(taskId) : tasks.remove(taskId);
    final allTasksCompleted =
        occurrence.tasks.isNotEmpty &&
        occurrence.tasks.every((task) => tasks.contains(task.id));
    _occurrences[index] = occurrence.copyWith(
      completedTaskIds: tasks,
      completedAt: allTasksCompleted ? DateTime.now() : null,
      clearCompletedAt: !allTasksCompleted,
    );
    await _saveOccurrences();
    notifyListeners();
  }

  ModeScheduleOccurrence? ensureOccurrence(
    ModeSchedule schedule,
    DateTime occurrenceStart,
    DateTime occurrenceEnd,
  ) {
    final key = occurrenceKey(schedule, occurrenceStart);
    final existing = occurrenceFor(key);
    if (existing != null) return existing;

    final occurrence = ModeScheduleOccurrence(
      key: key,
      scheduleId: schedule.id,
      modeId: schedule.modeId,
      scheduleName: schedule.name,
      startedAt: occurrenceStart,
      endedAt: occurrenceEnd,
      tasks: List.unmodifiable(schedule.tasks),
    );
    _occurrences.add(occurrence);
    unawaited(_saveOccurrences());
    return occurrence;
  }

  Future<void> _saveOccurrences() async {
    if (_occurrences.length > maxStoredOccurrences) {
      _occurrences.removeRange(0, _occurrences.length - maxStoredOccurrences);
    }
    await ModeTaskCompletionRepository.save(_occurrences);
  }

  bool isActive(ModeSchedule schedule, DateTime now) =>
      _activeWindowFor(schedule, now) != null;

  String? activeOccurrenceKey(ModeSchedule schedule, DateTime now) {
    final window = _activeWindowFor(schedule, now);
    return window == null ? null : occurrenceKey(schedule, window.start);
  }

  Future<void> _save() async {
    await ModeScheduleRepository.saveSchedules(_schedules);

    notifyListeners();
    _checkSchedules();
  }

  Future<void> _checkSchedules() async {
    final now = DateTime.now();
    var occurrencesChanged = false;

    for (var index = 0; index < _occurrences.length; index++) {
      final occurrence = _occurrences[index];
      if (occurrence.completedAt == null && !now.isBefore(occurrence.endedAt)) {
        _occurrences[index] = occurrence.copyWith(completedAt: now);
        occurrencesChanged = true;
      }
    }
    if (occurrencesChanged) await _saveOccurrences();

    for (final schedule in _schedules) {
      final activator = _activators[schedule.modeId];

      if (activator == null) continue;

      final window = _activeWindowFor(schedule, now);

      if (window == null) continue;

      final windowKey = '${schedule.id}:${window.start.toIso8601String()}';

      if (_activatedWindowKeys[schedule.id] == windowKey) continue;

      _activatedWindowKeys[schedule.id] = windowKey;
      ensureOccurrence(schedule, window.start, window.end);
      await activator(schedule, window.end.difference(now));
    }
  }

  ModeSchedule _withLegacyTasks(ModeSchedule schedule) {
    if (schedule.tasks.isNotEmpty) return schedule;

    return schedule.copyWith(
      tasks: [
        ModeTask(
          id: 'legacy-${schedule.id}',
          title: schedule.name,
          durationMinutes: schedule.duration.inMinutes,
          isPreset: false,
        ),
      ],
    );
  }

  List<ModeTask> _validatedTasks(List<ModeTask> tasks) {
    return tasks
        .where(
          (task) => task.title.trim().isNotEmpty && task.durationMinutes > 0,
        )
        .take(maxTasksPerSchedule)
        .toList(growable: false);
  }

  _ScheduleWindow? _activeWindowFor(ModeSchedule schedule, DateTime now) {
    if (!schedule.enabled ||
        (schedule.weekdays.isEmpty && schedule.dates.isEmpty)) {
      return null;
    }

    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = schedule.startTimeMinutes;
    final endMinutes = schedule.endTimeMinutes;

    if (startMinutes == endMinutes) return null;

    if (startMinutes < endMinutes) {
      if (!_isScheduledOn(schedule, now)) return null;
      if (currentMinutes < startMinutes || currentMinutes >= endMinutes) {
        return null;
      }

      final start = _dateWithMinutes(now, startMinutes);
      final end = _dateWithMinutes(now, endMinutes);

      return _ScheduleWindow(start: start, end: end);
    }

    if (currentMinutes >= startMinutes && _isScheduledOn(schedule, now)) {
      final start = _dateWithMinutes(now, startMinutes);
      final end = _dateWithMinutes(
        now.add(const Duration(days: 1)),
        endMinutes,
      );

      return _ScheduleWindow(start: start, end: end);
    }

    final previousDay = now.subtract(const Duration(days: 1));

    if (currentMinutes < endMinutes && _isScheduledOn(schedule, previousDay)) {
      final start = _dateWithMinutes(previousDay, startMinutes);
      final end = _dateWithMinutes(now, endMinutes);

      return _ScheduleWindow(start: start, end: end);
    }

    return null;
  }

  DateTime _dateWithMinutes(DateTime date, int minutesAfterMidnight) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      minutesAfterMidnight ~/ 60,
      minutesAfterMidnight % 60,
    );
  }

  List<ModeSchedule> schedulesForDay(DateTime date) {
    final previousDay = date.subtract(const Duration(days: 1));
    return _sortedSchedules(
      _schedules.where((schedule) {
        if (!schedule.enabled) return false;
        if (_isScheduledOn(schedule, date)) return true;
        return schedule.startTimeMinutes > schedule.endTimeMinutes &&
            _isScheduledOn(schedule, previousDay);
      }).toList(),
    );
  }

  bool _isScheduledOn(ModeSchedule schedule, DateTime date) {
    return schedule.repeatWeekly
        ? schedule.weekdays.contains(date.weekday)
        : schedule.dates.contains(_dateKey(date));
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  List<ModeSchedule> _sortedSchedules(List<ModeSchedule> schedules) {
    return schedules..sort((a, b) {
      if (a.weekdays.isEmpty) return 1;
      if (b.weekdays.isEmpty) return -1;

      final weekdayComparison = a.weekdays.first.compareTo(b.weekdays.first);

      if (weekdayComparison != 0) return weekdayComparison;

      return a.startTimeMinutes.compareTo(b.startTimeMinutes);
    });
  }

  @override
  void dispose() {
    stopRunner();
    super.dispose();
  }
}

class _ScheduleWindow {
  final DateTime start;
  final DateTime end;

  const _ScheduleWindow({required this.start, required this.end});
}
