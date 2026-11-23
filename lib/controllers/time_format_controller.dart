
import 'package:flutter/material.dart';

import '../data/repository/settings_repository.dart';

final timeFormatController = TimeFormatController();

class TimeFormatController extends ValueNotifier<bool> {
  TimeFormatController() : super(false);

  Future<void> load() async {
    value = await SettingsRepository.loadUse24HourTime();
  }

  Future<void> setUse24HourTime(bool use24HourTime) async {
    value = use24HourTime;
    await SettingsRepository.saveUse24HourTime(use24HourTime);
  }
}

String formatScheduleTime(TimeOfDay time, {required bool use24HourTime}) {
  final minute = time.minute.toString().padLeft(2, '0');

  if (use24HourTime) {
    return '${time.hour.toString().padLeft(2, '0')}:$minute';
  }

  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
}
