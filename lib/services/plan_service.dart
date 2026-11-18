import 'package:shared_preferences/shared_preferences.dart';

class Activity {
  final String title, description;
  const Activity(this.title, this.description);
}

const Map<String, List<Activity>> kActivities = {
  'Reading': [
    Activity('Read a few pages', 'Pick a book you enjoy and read without your phone nearby.'),
    Activity('Read something new', 'Try a short story or a chapter from a book you have not opened yet.'),
    Activity('Reread a favorite', 'Return to a passage you love and enjoy it slowly.'),
    Activity('Read by soft light', 'Find a cozy spot with warm light and read quietly.'),
  ],
  'Walking': [
    Activity('Easy walk outside', 'Leave your phone at home or in a bag and notice your surroundings.'),
    Activity('Walk to a new place', 'Choose a street or park you have not visited recently.'),
    Activity('Slow mindful walk', 'Walk slowly and pay attention to sounds and smells.'),
    Activity('Walk with someone', 'Invite a friend or family member for a phone-free stroll.'),
  ],
  'Music': [
    Activity('Listen to an album', 'Play a full album from start to finish and just listen.'),
    Activity('Play an instrument', 'Pick up an instrument and play anything that feels good.'),
    Activity('Discover new music', 'Put on music you have never heard and see how it feels.'),
    Activity('Sing along', 'Choose songs you love and sing without any screen.'),
  ],
  'Cooking': [
    Activity('Cook a simple meal', 'Make something easy and enjoy each step of it.'),
    Activity('Try a new recipe', 'Follow a printed or remembered recipe instead of a screen.'),
    Activity('Prepare a snack', 'Make a small snack slowly and eat it mindfully.'),
    Activity('Bake something', 'Bake bread, cookies or anything warm and comforting.'),
  ],
  'Exercise': [
    Activity('Gentle stretching', 'Stretch your body slowly and breathe deeply.'),
    Activity('Short workout', 'Do a simple routine you already know at your own pace.'),
    Activity('Yoga flow', 'Move through a few poses that feel calming.'),
    Activity('Bodyweight circuit', 'A few rounds of squats, push-ups and planks.'),
  ],
  'Creative activities': [
    Activity('Draw or doodle', 'Grab paper and a pen and draw whatever comes to mind.'),
    Activity('Write freely', 'Write in a notebook for a few minutes without editing.'),
    Activity('Make something by hand', 'Craft, paint or build something small.'),
    Activity('Photograph with intention', 'Look for beauty around you and notice details.'),
  ],
  'Relaxing': [
    Activity('Quiet sit', 'Sit comfortably, breathe slowly and let your mind settle.'),
    Activity('Warm drink break', 'Make tea or coffee and enjoy it without distractions.'),
    Activity('Lie down and rest', 'Close your eyes and rest, no screens and no pressure.'),
    Activity('Gentle breathing', 'Try slow breathing: in for 4, out for 6.'),
  ],
  'Spending time with others': [
    Activity('Have a real conversation', 'Talk with someone close to you, phones away.'),
    Activity('Share a meal', 'Eat together and keep phones off the table.'),
    Activity('Play a game together', 'A board game or cards, anything social and screen-free.'),
    Activity('Call or visit someone', 'Reach out to someone you have been meaning to see.'),
  ],
};

class MomentSession {
  final int day, minutes;
  final DateTime start;
  const MomentSession(this.day, this.minutes, this.start);
  DateTime get end => start.add(Duration(minutes: minutes));
}

class PlanDay {
  final int day;
  final String category, altCategory;
  final Activity step, alternative;
  final int minutes;
  const PlanDay(this.day, this.category, this.step, this.altCategory,
      this.alternative, this.minutes);
}

class PlanData {
  final List<PlanDay> days;
  final String timeOfDay, goal;
  final int currentDay;
  final Set<int> completed;
  final int total;
  final List<String> interests; // onboarding'de seçilen ilgi alanları
  final Map<int, int> goalOverrides; // gün -> kullanıcının seçtiği dakika
  final Map<int, int> minutesDone; // gün -> tamamlanan dakika
  const PlanData(this.days, this.timeOfDay, this.goal, this.currentDay,
      this.completed, this.total,
      {this.interests = const [],
      this.goalOverrides = const {},
      this.minutesDone = const {}});

  PlanDay get today => days[currentDay - 1];

  int minutesFor(int day) => goalOverrides[day] ?? days[day - 1].minutes;
}

class PlanService {
  static Future<PlanData> load() async {
    final p = await SharedPreferences.getInstance();

    final interests = (p.getStringList('onb_interests') ?? [])
        .where(kActivities.containsKey)
        .toList();
    final cats = interests.isEmpty
        ? ['Reading', 'Walking', 'Relaxing']
        : interests;
    final time = (p.getStringList('onb_time') ?? ['Evening']).first;
    final goal = (p.getStringList('onb_goal') ?? ['Create more phone-free moments']).first;
    final base = int.tryParse(
            (p.getStringList('onb_duration') ?? ['30 minutes']).first.split(' ').first) ??
        30;

    final total = (int.tryParse((p.getStringList('onb_length') ?? ['14 days'])
                .first
                .split(' ')
                .first) ??
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

      days.add(PlanDay(
        d,
        cat,
        list[round % list.length],
        altCat,
        altList[(round + 1) % altList.length],
        minutes,
      ));
    }

    var startStr = p.getString('plan_start');
    if (startStr == null) {
      startStr = DateTime.now().toIso8601String();
      await p.setString('plan_start', startStr);
    }
    final start = DateTime.parse(startStr);
    final now = DateTime.now();
    final elapsed = DateTime(now.year, now.month, now.day)
            .difference(DateTime(start.year, start.month, start.day))
            .inDays +
        (p.getInt('plan_offset') ?? 0);
    final current = elapsed < 0 ? 1 : (elapsed + 1 > total ? total : elapsed + 1);

    final completed = (p.getStringList('plan_completed') ?? [])
        .map(int.parse)
        .toSet();

    final goalOverrides = <int, int>{};
    final minutesDone = <int, int>{};
    for (var d = 1; d <= total; d++) {
      final g = p.getInt('plan_goal_$d');
      if (g != null) goalOverrides[d] = g;
      final m = p.getInt('plan_done_min_$d');
      if (m != null) minutesDone[d] = m;
    }

    return PlanData(days, time, goal, current, completed, total,
        interests: interests,
        goalOverrides: goalOverrides,
        minutesDone: minutesDone);
  }

  static Future<void> complete(int day, {int? minutes}) async {
    final p = await SharedPreferences.getInstance();
    final set = (p.getStringList('plan_completed') ?? []).toSet()..add('$day');
    await p.setStringList('plan_completed', set.toList());
    if (minutes != null) await p.setInt('plan_done_min_$day', minutes);
  }

  static Future<void> setGoal(int day, int minutes) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('plan_goal_$day', minutes);
  }

  static Future<bool> introSeen() async =>
      (await SharedPreferences.getInstance()).getBool('journey_intro_seen') ??
      false;

  static Future<void> markIntroSeen() async =>
      (await SharedPreferences.getInstance()).setBool('journey_intro_seen', true);

  static Future<void> debugNextDay() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('plan_offset', (p.getInt('plan_offset') ?? 0) + 1);
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
        day, minutes, DateTime.fromMillisecondsSinceEpoch(start));
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
    await p.setString('plan_start',
        DateTime.now().subtract(Duration(days: n)).toIso8601String());
    await p.setInt('plan_offset', 0);
    await p.setStringList(
        'plan_completed', [for (var d = 1; d <= n; d++) '$d']);
    for (var d = 1; d <= n; d++) {
      await p.setInt('plan_done_min_$d', plan.minutesFor(d));
    }
    await clearMoment();
  }

  static Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('plan_start');
    await p.remove('plan_completed');
    await p.remove('plan_offset');
    await p.remove('journey_intro_seen');
    await clearMoment();
    for (var d = 1; d <= 30; d++) {
      await p.remove('plan_goal_$d');
      await p.remove('plan_done_min_$d');
    }
  }
}
