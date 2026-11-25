import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/mode_schedule.dart';

class ModeScheduleRepository {
  static const _schedulesKey = 'mode_schedules';

  static Future<List<ModeSchedule>> loadSchedules() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedSchedules = preferences.getStringList(_schedulesKey) ?? [];

    final schedules = <ModeSchedule>[];

    for (final encodedSchedule in encodedSchedules) {
      try {
        schedules.add(
          ModeSchedule.fromJson(
            Map<String, Object?>.from(
              jsonDecode(encodedSchedule) as Map,
            ),
          ),
        );
      } catch (_) {
        // Ignore stale schedule records from older local builds.
      }
    }

    return schedules;
  }

  static Future<void> saveSchedules(List<ModeSchedule> schedules) async {
    final preferences = await SharedPreferences.getInstance();

    final encodedSchedules = schedules.map((schedule) {
      return jsonEncode(schedule.toJson());
    }).toList();

    await preferences.setStringList(_schedulesKey, encodedSchedules);
  }
}