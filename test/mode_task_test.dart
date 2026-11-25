import 'package:flutter_test/flutter_test.dart';
import 'package:rest_for_more/models/mode_schedule.dart';
import 'package:rest_for_more/models/mode_schedule_occurrence.dart';
import 'package:rest_for_more/models/mode_task.dart';
import 'package:rest_for_more/models/mode_task_presets.dart';

void main() {
  test('mode tasks survive schedule JSON round trips', () {
    const schedule = ModeSchedule(
      id: 'schedule-1',
      name: 'Morning',
      modeId: ModeId.morning,
      weekdays: [1],
      startTimeMinutes: 420,
      endTimeMinutes: 450,
      enabled: true,
      tasks: [
        ModeTask(
          id: 'custom-1',
          title: 'Breakfast',
          description: 'Eat without a screen.',
          durationMinutes: 15,
          isPreset: false,
        ),
      ],
    );

    final decoded = ModeSchedule.fromJson(schedule.toJson());

    expect(decoded.tasks, hasLength(1));
    expect(decoded.tasks.single.title, 'Breakfast');
    expect(decoded.tasks.single.durationMinutes, 15);
    expect(decoded.tasks.single.isPreset, isFalse);
  });

  test('new modes have independent preset task lists', () {
    final first = presetsForMode(ModeId.focus);
    final second = presetsForMode(ModeId.focus);

    first.removeAt(0);

    expect(first.length, second.length - 1);
    expect(second, isNotEmpty);
  });

  test('legacy schedules can be decoded without task data', () {
    final schedule = ModeSchedule.fromJson({
      'id': 'legacy',
      'name': 'Old schedule',
      'modeId': 'focus',
      'dates': <String>[],
      'repeatWeekly': true,
      'weekdays': [1],
      'startTimeMinutes': 600,
      'endTimeMinutes': 630,
      'enabled': true,
    });

    expect(schedule.tasks, isEmpty);
    expect(schedule.duration, const Duration(minutes: 30));
  });

  test('occurrence snapshots preserve their original task definitions', () {
    final occurrence = ModeScheduleOccurrence(
      key: 'schedule-1:2026-11-25T13:00:00.000',
      scheduleId: 'schedule-1',
      modeId: ModeId.reading,
      scheduleName: 'Reading',
      startedAt: DateTime(2026, 11, 25, 13),
      endedAt: DateTime(2026, 11, 25, 14),
      tasks: const [
        ModeTask(
          id: 'task-1',
          title: 'Read chapter one',
          durationMinutes: 20,
          isPreset: true,
        ),
      ],
      completedTaskIds: const {'task-1'},
    );

    final decoded = ModeScheduleOccurrence.fromJson(occurrence.toJson());

    expect(decoded.tasks.single.title, 'Read chapter one');
    expect(decoded.completedTaskIds, contains('task-1'));
  });
}
