import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mode_schedule.dart';

final modeScheduleService = ModeScheduleService();

typedef ModeScheduleActivator = FutureOr<void> Function(
  ModeSchedule schedule,
  Duration remaining,
);

class ModeScheduleService extends ChangeNotifier {
  static const _schedulesKey = 'mode_schedules';
  static const _runnerInterval = Duration(seconds: 30);

  final List<ModeSchedule> _schedules = [];
  final Map<ModeId, ModeScheduleActivator> _activators = {};
  final Map<String, String> _activatedWindowKeys = {};

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
    final preferences = await SharedPreferences.getInstance();
    final encodedSchedules = preferences.getStringList(_schedulesKey) ?? [];

    _schedules
      ..clear()
      ..addAll(_deduplicateByMode(_decodeSchedules(encodedSchedules)));

    notifyListeners();
  }

  Future<void> addSchedule({
    required ModeId modeId,
    required List<int> weekdays,
    required int startTimeMinutes,
    required int endTimeMinutes,
  }) async {
    final schedule = ModeSchedule(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      modeId: modeId,
      weekdays: [...weekdays]..sort(),
      startTimeMinutes: startTimeMinutes,
      endTimeMinutes: endTimeMinutes,
      enabled: true,
    );

    _schedules.removeWhere((schedule) => schedule.modeId == modeId);
    _schedules.add(schedule);
    await _save();
  }

  Future<void> updateSchedule(ModeSchedule schedule) async {
    final index = _schedules.indexWhere((item) => item.id == schedule.id);

    if (index == -1) return;

    _schedules[index] = schedule;
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

  Future<void> _save() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedSchedules = _schedules.map((schedule) {
      return jsonEncode(schedule.toJson());
    }).toList();

    await preferences.setStringList(_schedulesKey, encodedSchedules);
    notifyListeners();
    _checkSchedules();
  }

  Future<void> _checkSchedules() async {
    final now = DateTime.now();

    for (final schedule in _schedules) {
      final activator = _activators[schedule.modeId];

      if (activator == null) continue;

      final window = _activeWindowFor(schedule, now);

      if (window == null) continue;

      final windowKey = '${schedule.id}:${window.start.toIso8601String()}';

      if (_activatedWindowKeys[schedule.id] == windowKey) continue;

      _activatedWindowKeys[schedule.id] = windowKey;
      await activator(schedule, window.end.difference(now));
    }
  }

  _ScheduleWindow? _activeWindowFor(ModeSchedule schedule, DateTime now) {
    if (!schedule.enabled || schedule.weekdays.isEmpty) return null;

    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = schedule.startTimeMinutes;
    final endMinutes = schedule.endTimeMinutes;

    if (startMinutes == endMinutes) return null;

    if (startMinutes < endMinutes) {
      if (!schedule.weekdays.contains(now.weekday)) return null;
      if (currentMinutes < startMinutes || currentMinutes >= endMinutes) {
        return null;
      }

      final start = _dateWithMinutes(now, startMinutes);
      final end = _dateWithMinutes(now, endMinutes);

      return _ScheduleWindow(start: start, end: end);
    }

    if (currentMinutes >= startMinutes &&
        schedule.weekdays.contains(now.weekday)) {
      final start = _dateWithMinutes(now, startMinutes);
      final end = _dateWithMinutes(
        now.add(const Duration(days: 1)),
        endMinutes,
      );

      return _ScheduleWindow(start: start, end: end);
    }

    final previousDay = now.subtract(const Duration(days: 1));

    if (currentMinutes < endMinutes &&
        schedule.weekdays.contains(previousDay.weekday)) {
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

  List<ModeSchedule> _decodeSchedules(List<String> encodedSchedules) {
    final schedules = <ModeSchedule>[];

    for (final encodedSchedule in encodedSchedules) {
      try {
        schedules.add(
          ModeSchedule.fromJson(
            Map<String, Object?>.from(jsonDecode(encodedSchedule) as Map),
          ),
        );
      } catch (_) {
        // Ignore stale schedule records from older local builds.
      }
    }

    return schedules;
  }

  List<ModeSchedule> _deduplicateByMode(List<ModeSchedule> schedules) {
    final schedulesByMode = <ModeId, ModeSchedule>{};

    for (final schedule in schedules) {
      schedulesByMode[schedule.modeId] = schedule;
    }

    return schedulesByMode.values.toList();
  }

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
