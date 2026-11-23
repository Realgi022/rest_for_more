import 'package:flutter/material.dart';

import '../data/repository/settings_repository.dart';

final themeController = ThemeController();

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  Future<void> load() async {
    final nightModeOn = await SettingsRepository.loadNightMode();

    value = nightModeOn ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setNightMode(bool enabled) async {
    value = enabled ? ThemeMode.dark : ThemeMode.light;

    await SettingsRepository.saveNightMode(enabled);
  }
}