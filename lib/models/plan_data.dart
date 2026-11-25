  import 'plan_day.dart';

  class PlanData {
    final List<PlanDay> days;
    final String timeOfDay, goal;
    final int currentDay;
    final Set<int> completed;
    final int total;
    final List<String> interests; // onboarding'de seçilen ilgi alanları
    final Map<int, int> goalOverrides; // gün -> kullanıcının seçtiği dakika
    final Map<int, int> minutesDone; // gün -> tamamlanan dakika
    const PlanData(
      this.days,
      this.timeOfDay,
      this.goal,
      this.currentDay,
      this.completed,
      this.total, {
      this.interests = const [],
      this.goalOverrides = const {},
      this.minutesDone = const {},
    });

    PlanDay get today => days[currentDay - 1];

    int minutesFor(int day) => goalOverrides[day] ?? days[day - 1].minutes;
  }
