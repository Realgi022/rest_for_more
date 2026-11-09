import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeFormatController extends ValueNotifier<bool> {
  TimeFormatController() : super(false);

  static const _prefsKey = 'use_24_hour_time';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> setUse24HourTime(bool use24HourTime) async {
    value = use24HourTime;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, use24HourTime);
  }
}

final timeFormatController = TimeFormatController();

String formatScheduleTime(TimeOfDay time, {required bool use24HourTime}) {
  final minute = time.minute.toString().padLeft(2, '0');
  if (use24HourTime) {
    return '${time.hour.toString().padLeft(2, '0')}:$minute';
  }
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
}
