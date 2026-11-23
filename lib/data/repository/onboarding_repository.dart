import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  static const _onboardingDoneKey = 'onboarded';

  static Future<bool> isDone() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_onboardingDoneKey) ?? false;
  }

  static Future<void> saveAnswers(
    Map<String, List<String>> answers,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    for (final entry in answers.entries) {
      await preferences.setStringList(
        'onb_${entry.key}',
        entry.value,
      );
    }
  }

  static Future<void> setDone(bool done) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingDoneKey, done);
  }
  static Future<List<String>> loadAnswer(String key) async {
  final preferences = await SharedPreferences.getInstance();

  return preferences.getStringList('onb_$key') ?? [];
}

static Future<List<String>> loadTime() async {
  return (await loadAnswer('time')).isEmpty
      ? ['Evening']
      : loadAnswer('time');
}

static Future<List<String>> loadGoal() async {
  return (await loadAnswer('goal')).isEmpty
      ? ['Create more phone-free moments']
      : loadAnswer('goal');
}

static Future<List<String>> loadDuration() async {
  return (await loadAnswer('duration')).isEmpty
      ? ['30 minutes']
      : loadAnswer('duration');
}

static Future<List<String>> loadLength() async {
  return (await loadAnswer('length')).isEmpty
      ? ['14 days']
      : loadAnswer('length');
}
}