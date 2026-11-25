class ModeTask {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final bool isPreset;

  const ModeTask({
    required this.id,
    required this.title,
    this.description = '',
    required this.durationMinutes,
    required this.isPreset,
  });

  ModeTask copyWith({
    String? id,
    String? title,
    String? description,
    int? durationMinutes,
    bool? isPreset,
  }) {
    return ModeTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isPreset: isPreset ?? this.isPreset,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'durationMinutes': durationMinutes,
    'isPreset': isPreset,
  };

  factory ModeTask.fromJson(Map<String, Object?> json) {
    final duration = json['durationMinutes'] as int? ?? 1;
    if (duration < 1) throw const FormatException('Task duration is invalid');

    return ModeTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      durationMinutes: duration,
      isPreset: json['isPreset'] as bool? ?? false,
    );
  }

  int get durationSeconds => durationMinutes * 60;
}
