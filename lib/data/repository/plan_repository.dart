import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_repository.dart';
import '../../models/plan_data.dart';

class PlanRepository {
static Future<List<String>> loadInterests() async {
  return OnboardingRepository.loadAnswer('interests');
}

static Future<List<String>> loadTime() async {
  return OnboardingRepository.loadTime();
}

static Future<List<String>> loadGoal() async {
  return OnboardingRepository.loadGoal();
}

static Future<List<String>> loadDuration() async {
  return OnboardingRepository.loadDuration();
}

static Future<List<String>> loadLength() async {
  return OnboardingRepository.loadLength();
}
  static Future<String?> loadPlanStart() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('plan_start');
  }

  static Future<void> savePlanStart(String start) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('plan_start', start);
  }

  static Future<int> loadPlanOffset() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('plan_offset') ?? 0;
  }

  static Future<void> savePlanOffset(int offset) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('plan_offset', offset);
  }

  static Future<List<String>> loadCompleted() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList('plan_completed') ?? [];
  }

  static Future<void> saveCompleted(List<String> completed) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('plan_completed', completed);
  }

  static Future<int?> loadGoalOverride(int day) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('plan_goal_$day');
  }

  static Future<void> saveGoalOverride(int day, int minutes) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('plan_goal_$day', minutes);
  }

  static Future<int?> loadMinutesDone(int day) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('plan_done_min_$day');
  }

  static Future<void> saveMinutesDone(int day, int minutes) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('plan_done_min_$day', minutes);
  }

  static Future<void> complete(int day, {int? minutes}) async {
    final p = await SharedPreferences.getInstance();

    final set = (p.getStringList('plan_completed') ?? []).toSet()..add('$day');

    await p.setStringList('plan_completed', set.toList());

    if (minutes != null) {
      await p.setInt('plan_done_min_$day', minutes);
    }
  }

  static Future<void> setGoal(int day, int minutes) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('plan_goal_$day', minutes);
  }

  static Future<bool> introSeen() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('journey_intro_seen') ?? false;
  }

  static Future<void> markIntroSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('journey_intro_seen', true);
  }

  static Future<void> debugNextDay() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('plan_offset', (p.getInt('plan_offset') ?? 0) + 1);
  }

  static Future<void> debugSeedProgress(
    PlanData plan, {
    int doneDays = 4,
  }) async {
    final p = await SharedPreferences.getInstance();

    final n = doneDays < plan.total - 1 ? doneDays : plan.total - 1;

    final start = DateTime.now().subtract(Duration(days: n));

    await p.setString('plan_start', start.toIso8601String());
    await p.setInt('plan_offset', 0);

    await p.setStringList(
      'plan_completed',
      List.generate(n, (i) => '${i + 1}'),
    );

    for (var d = 1; d <= n; d++) {
      await p.setInt('plan_done_min_$d', plan.minutesFor(d));
    }
  }

  static Future<void> reset() async {
    final p = await SharedPreferences.getInstance();

    await p.remove('plan_start');
    await p.remove('plan_completed');
    await p.remove('plan_offset');
    await p.remove('journey_intro_seen');

    for (var d = 1; d <= 30; d++) {
      await p.remove('plan_goal_$d');
      await p.remove('plan_done_min_$d');
    }
  }
}
