import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';
import '../models/moment_session.dart';
import '../models/plan_day.dart';
import '../models/plan_data.dart';
import '../data/repository/plan_repository.dart';

class PlanService {
  static Future<PlanData> load() async {

    final interests = (await PlanRepository.loadInterests())
        .where(kActivities.containsKey)
        .toList();

    final cats = interests.isEmpty
        ? ['Reading', 'Walking', 'Relaxing']
        : interests;

    final time = (await PlanRepository.loadTime()).first;

    final goal = (await PlanRepository.loadGoal()).first;

    final base =
        int.tryParse(
          (await PlanRepository.loadDuration()).first.split(' ').first,
        ) ??
        30;

    final total =
        (int.tryParse(
                  (await PlanRepository.loadLength()).first.split(' ').first,
                ) ??
                14)
            .clamp(1, 30)
            .toInt();

    final days = <PlanDay>[];
    for (var d = 1; d <= total; d++) {
      final i = d - 1;
      final minutes = base;

      final round = i ~/ cats.length;
      final cat = cats[i % cats.length];
      final altCat = cats[(i + 1) % cats.length];
      final list = kActivities[cat]!;
      final altList = kActivities[altCat]!;

      days.add(
        PlanDay(
          d,
          cat,
          list[round % list.length],
          altCat,
          altList[(round + 1) % altList.length],
          minutes,
        ),
      );
    }

    var startStr = await PlanRepository.loadPlanStart();

    if (startStr == null) {
      startStr = DateTime.now().toIso8601String();
      await PlanRepository.savePlanStart(startStr);
    }

    final start = DateTime.parse(startStr);

    final now = DateTime.now();

    final elapsed =
        DateTime(
          now.year,
          now.month,
          now.day,
        ).difference(DateTime(start.year, start.month, start.day)).inDays +
        await PlanRepository.loadPlanOffset();
    final current = elapsed < 0
        ? 1
        : (elapsed + 1 > total ? total : elapsed + 1);

    final completed = (await PlanRepository.loadCompleted())
        .map(int.parse)
        .toSet();

    final goalOverrides = <int, int>{};
    final minutesDone = <int, int>{};

    for (var d = 1; d <= total; d++) {
      final g = await PlanRepository.loadGoalOverride(d);
      if (g != null) goalOverrides[d] = g;

      final m = await PlanRepository.loadMinutesDone(d);
      if (m != null) minutesDone[d] = m;
    }

    return PlanData(
      days,
      time,
      goal,
      current,
      completed,
      total,
      interests: interests,
      goalOverrides: goalOverrides,
      minutesDone: minutesDone,
    );
  }

  static Future<void> complete(int day, {int? minutes}) async {
    await PlanRepository.complete(day, minutes: minutes);
  }

  static Future<void> setGoal(int day, int minutes) async {
    await PlanRepository.setGoal(day, minutes);
  }

  static Future<bool> introSeen() async {
    return await PlanRepository.introSeen();
  }

  static Future<void> markIntroSeen() async {
    await PlanRepository.markIntroSeen();
  }

  static Future<void> debugNextDay() async {
    await PlanRepository.debugNextDay();
  }

  static Future<void> startMoment(int day, int minutes) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('moment_day', day);
    await p.setInt('moment_minutes', minutes);
    await p.setInt('moment_start', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<MomentSession?> activeMoment() async {
    final p = await SharedPreferences.getInstance();
    final day = p.getInt('moment_day');
    final minutes = p.getInt('moment_minutes');
    final start = p.getInt('moment_start');
    if (day == null || minutes == null || start == null) return null;
    return MomentSession(
      day,
      minutes,
      DateTime.fromMillisecondsSinceEpoch(start),
    );
  }

  static Future<void> clearMoment() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('moment_day');
    await p.remove('moment_minutes');
    await p.remove('moment_start');
  }

  static Future<void> debugSeedProgress({int doneDays = 4}) async {
    final plan = await load();
    final n = doneDays < plan.total - 1 ? doneDays : plan.total - 1;
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'plan_start',
      DateTime.now().subtract(Duration(days: n)).toIso8601String(),
    );
    await p.setInt('plan_offset', 0);
    await p.setStringList('plan_completed', [
      for (var d = 1; d <= n; d++) '$d',
    ]);
    for (var d = 1; d <= n; d++) {
      await p.setInt('plan_done_min_$d', plan.minutesFor(d));
    }
    await clearMoment();
  }

  static Future<void> reset() async {
    await PlanRepository.reset();
    await clearMoment();
  }
}
