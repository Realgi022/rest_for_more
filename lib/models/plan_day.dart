import 'activity.dart';

class PlanDay {
  final int day;
  final String category, altCategory;
  final Activity step, alternative;
  final int minutes;
  const PlanDay(
    this.day,
    this.category,
    this.step,
    this.altCategory,
    this.alternative,
    this.minutes,
  );
}
