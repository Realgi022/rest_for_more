import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _nightModeKey = 'night_mode_on';
  static const _timeFormatKey = 'use_24_hour_time';
  static const _weekStartKey = 'week_starts_on_sunday';
  static const _languageKey = 'app_language';

  // Night mode
  static Future<bool> loadNightMode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_nightModeKey) ?? false;
  }

  static Future<void> saveNightMode(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_nightModeKey, enabled);
  }

  // Time format
  static Future<bool> loadUse24HourTime() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_timeFormatKey) ?? false;
  }

  static Future<void> saveUse24HourTime(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_timeFormatKey, enabled);
  }

  // First day of week
  static Future<bool> loadSundayFirst() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_weekStartKey) ?? false;
  }

  static Future<void> saveSundayFirst(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_weekStartKey, enabled);
  }

  // Language
  static Future<String?> loadLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_languageKey);
  }

  static Future<void> saveLanguage(String language) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, language);
  }
}