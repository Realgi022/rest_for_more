import 'mode_task.dart';

enum ModeId {
  focus('focus', 'Focus'),
  reading('reading', 'Reading'),
  evening('evening', 'Evening'),
  morning('morning', 'Morning');

  final String value;
  final String label;

  const ModeId(this.value, this.label);

  static ModeId fromValue(String value) {
    return ModeId.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => ModeId.focus,
    );
  }
}

class ModeSchedule {
  final String id;
  final String name;
  final ModeId modeId;
  final List<String> dates;
  final bool repeatWeekly;
  final List<int> weekdays;
  final int startTimeMinutes;
  final int endTimeMinutes;
  final bool enabled;
  final List<ModeTask> tasks;

  const ModeSchedule({
    required this.id,
    required this.name,
    required this.modeId,
    this.dates = const [],
    this.repeatWeekly = true,
    required this.weekdays,
    required this.startTimeMinutes,
    required this.endTimeMinutes,
    required this.enabled,
    this.tasks = const [],
  });

  Duration get duration {
    final minutes = endTimeMinutes > startTimeMinutes
        ? endTimeMinutes - startTimeMinutes
        : minutesPerDay - startTimeMinutes + endTimeMinutes;

    return Duration(minutes: minutes);
  }

  ModeSchedule copyWith({
    String? id,
    String? name,
    ModeId? modeId,
    List<String>? dates,
    bool? repeatWeekly,
    List<int>? weekdays,
    int? startTimeMinutes,
    int? endTimeMinutes,
    bool? enabled,
    List<ModeTask>? tasks,
  }) {
    return ModeSchedule(
      id: id ?? this.id,
      name: name ?? this.name,
      modeId: modeId ?? this.modeId,
      dates: dates ?? this.dates,
      repeatWeekly: repeatWeekly ?? this.repeatWeekly,
      weekdays: weekdays ?? this.weekdays,
      startTimeMinutes: startTimeMinutes ?? this.startTimeMinutes,
      endTimeMinutes: endTimeMinutes ?? this.endTimeMinutes,
      enabled: enabled ?? this.enabled,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'modeId': modeId.value,
      'dates': dates,
      'repeatWeekly': repeatWeekly,
      'weekdays': weekdays,
      'startTimeMinutes': startTimeMinutes,
      'endTimeMinutes': endTimeMinutes,
      'enabled': enabled,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory ModeSchedule.fromJson(Map<String, Object?> json) {
    final modeId = ModeId.fromValue(json['modeId'] as String);
    final encodedTasks = json['tasks'] as List?;
    final tasks = encodedTasks == null
        ? <ModeTask>[]
        : encodedTasks
              .map(
                (task) =>
                    ModeTask.fromJson(Map<String, Object?>.from(task as Map)),
              )
              .toList();

    return ModeSchedule(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Schedule',
      modeId: modeId,
      dates: (json['dates'] as List?)?.cast<String>() ?? const [],
      repeatWeekly: json['repeatWeekly'] as bool? ?? true,
      weekdays: (List<int>.from((json['weekdays'] as List).cast<int>())
        ..sort()),
      startTimeMinutes: json['startTimeMinutes'] as int,
      endTimeMinutes: json['endTimeMinutes'] as int,
      enabled: json['enabled'] as bool? ?? true,
      tasks: tasks,
    );
  }

  static const minutesPerDay = 24 * 60;
}
