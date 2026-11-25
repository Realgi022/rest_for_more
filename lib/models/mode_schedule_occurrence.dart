import 'mode_task.dart';
import 'mode_schedule.dart';

class ModeScheduleOccurrence {
  final String key;
  final String scheduleId;
  final ModeId modeId;
  final String scheduleName;
  final DateTime startedAt;
  final DateTime endedAt;
  final List<ModeTask> tasks;
  final Set<String> completedTaskIds;
  final DateTime? completedAt;

  const ModeScheduleOccurrence({
    required this.key,
    required this.scheduleId,
    required this.modeId,
    required this.scheduleName,
    required this.startedAt,
    required this.endedAt,
    required this.tasks,
    this.completedTaskIds = const {},
    this.completedAt,
  });

  ModeScheduleOccurrence copyWith({
    List<ModeTask>? tasks,
    Set<String>? completedTaskIds,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return ModeScheduleOccurrence(
      key: key,
      scheduleId: scheduleId,
      modeId: modeId,
      scheduleName: scheduleName,
      startedAt: startedAt,
      endedAt: endedAt,
      tasks: tasks ?? this.tasks,
      completedTaskIds: completedTaskIds ?? this.completedTaskIds,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }

  Map<String, Object?> toJson() => {
    'key': key,
    'scheduleId': scheduleId,
    'modeId': modeId.value,
    'scheduleName': scheduleName,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt.toIso8601String(),
    'tasks': tasks.map((task) => task.toJson()).toList(),
    'completedTaskIds': completedTaskIds.toList(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory ModeScheduleOccurrence.fromJson(Map<String, Object?> json) {
    final encodedTasks = json['tasks'] as List? ?? const [];
    return ModeScheduleOccurrence(
      key: json['key'] as String,
      scheduleId: json['scheduleId'] as String,
      modeId: ModeId.fromValue(json['modeId'] as String? ?? 'focus'),
      scheduleName: json['scheduleName'] as String? ?? 'Schedule',
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      tasks: encodedTasks
          .map(
            (task) => ModeTask.fromJson(Map<String, Object?>.from(task as Map)),
          )
          .toList(growable: false),
      completedTaskIds:
          ((json['completedTaskIds'] as List?)?.cast<String>() ?? const [])
              .toSet(),
      completedAt: (json['completedAt'] as String?) == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );
  }
}
