import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ThemeController themeController = ThemeController();

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  static const _nightModeKey = 'night_mode_on';

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final nightModeOn = preferences.getBool(_nightModeKey) ?? false;

    value = nightModeOn ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setNightMode(bool enabled) async {
    value = enabled ? ThemeMode.dark : ThemeMode.light;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_nightModeKey, enabled);
  }
}
