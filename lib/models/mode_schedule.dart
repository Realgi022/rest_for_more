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
    };
  }

  factory ModeSchedule.fromJson(Map<String, Object?> json) {
    return ModeSchedule(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Schedule',
      modeId: ModeId.fromValue(json['modeId'] as String),
      dates: (json['dates'] as List?)?.cast<String>() ?? const [],
      repeatWeekly: json['repeatWeekly'] as bool? ?? true,
      weekdays: (json['weekdays'] as List).cast<int>()..sort(),
      startTimeMinutes: json['startTimeMinutes'] as int,
      endTimeMinutes: json['endTimeMinutes'] as int,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  static const minutesPerDay = 24 * 60;
}
