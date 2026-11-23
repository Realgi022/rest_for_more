import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';
import '../data/repository/settings_repository.dart';

final appLanguageController = AppLanguageController();

class AppLanguageController extends ValueNotifier<AppLanguage> {
  AppLanguageController() : super(AppLanguage.english);

  Future<void> load() async {
    final languageCode = await SettingsRepository.loadLanguage();
    value = AppLanguage.fromCode(languageCode);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (value == language) return;

    value = language;
    await SettingsRepository.saveLanguage(language.code);
  }
}