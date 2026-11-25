import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/mode_schedule_occurrence.dart';

class ModeTaskCompletionRepository {
  static const _key = 'mode_schedule_task_completions';

  static Future<List<ModeScheduleOccurrence>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getStringList(_key) ?? const <String>[];
    final occurrences = <ModeScheduleOccurrence>[];

    for (final value in encoded) {
      try {
        occurrences.add(
          ModeScheduleOccurrence.fromJson(
            Map<String, Object?>.from(jsonDecode(value) as Map),
          ),
        );
      } catch (_) {
        // Ignore stale occurrence records from older local builds.
      }
    }

    return occurrences;
  }

  static Future<void> save(List<ModeScheduleOccurrence> occurrences) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _key,
      occurrences.map((occurrence) => jsonEncode(occurrence.toJson())).toList(),
    );
  }
}
