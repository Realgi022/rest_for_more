import 'package:shared_preferences/shared_preferences.dart';

import '../../models/moment_session.dart';

class MomentRepository {
  static Future<void> startMoment(int day, int minutes) async {
    final p = await SharedPreferences.getInstance();

    await p.setInt('moment_day', day);
    await p.setInt('moment_minutes', minutes);
    await p.setString('moment_start', DateTime.now().toIso8601String());
  }

  static Future<MomentSession?> activeMoment() async {
    final p = await SharedPreferences.getInstance();

    final day = p.getInt('moment_day');
    final minutes = p.getInt('moment_minutes');
    final startStr = p.getString('moment_start');

    if (day == null || minutes == null || startStr == null) {
      return null;
    }

    return MomentSession(day, minutes, DateTime.parse(startStr));
  }

  static Future<void> clearMoment() async {
    final p = await SharedPreferences.getInstance();

    await p.remove('moment_day');
    await p.remove('moment_minutes');
    await p.remove('moment_start');
  }
}