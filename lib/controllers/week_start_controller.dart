
import 'package:flutter/foundation.dart';

import '../data/repository/settings_repository.dart';

final weekStartController = WeekStartController();

class WeekStartController extends ValueNotifier<bool> {
  WeekStartController() : super(false);

  Future<void> load() async {
    value = await SettingsRepository.loadSundayFirst();
  }

  Future<void> setSundayFirst(bool sundayFirst) async {
    value = sundayFirst;
    await SettingsRepository.saveSundayFirst(sundayFirst);
  }
}
