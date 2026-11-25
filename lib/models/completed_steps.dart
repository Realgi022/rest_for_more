
class CompletedStep {
  final int day;
  final String category;
  final String title;
  final String description;
  final DateTime completedAt;
  final int minutes;

  const CompletedStep({
    required this.day,
    required this.category,
    required this.title,
    required this.description,
    required this.completedAt,
    required this.minutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'category': category,
      'title': title,
      'description': description,
      'completedAt': completedAt.toIso8601String(),
      'minutes': minutes,
    };
  }

  factory CompletedStep.fromJson(Map<String, dynamic> json) {
    return CompletedStep(
      day: json['day'] as int,
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      minutes: json['minutes'] as int,
    );
  }
}
