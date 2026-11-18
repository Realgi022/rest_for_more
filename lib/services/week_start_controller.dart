import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeekStartController extends ValueNotifier<bool> {
  WeekStartController() : super(false);

  static const _prefsKey = 'week_starts_on_sunday';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> setSundayFirst(bool sundayFirst) async {
    value = sundayFirst;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, sundayFirst);
  }
}

final weekStartController = WeekStartController();
