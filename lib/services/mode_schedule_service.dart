import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mode_schedule.dart';

final modeScheduleService = ModeScheduleService();

class ModeScheduleService extends ChangeNotifier {
  static const _schedulesKey = 'mode_schedules';

  final List<ModeSchedule> _schedules = [];

  List<ModeSchedule> get schedules {
    return List.unmodifiable(_sortedSchedules(_schedules));
  }

  List<ModeSchedule> schedulesFor(ModeId modeId) {
    return _sortedSchedules(
      _schedules.where((schedule) => schedule.modeId == modeId).toList(),
    );
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
}
