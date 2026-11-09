import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rest_for_more/services/time_format_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('formats midnight, noon and afternoon in both formats', () {
    for (final (time, twelve, twentyFour) in [
      (const TimeOfDay(hour: 0, minute: 5), '12:05 AM', '00:05'),
      (const TimeOfDay(hour: 12, minute: 0), '12:00 PM', '12:00'),
      (const TimeOfDay(hour: 14, minute: 30), '2:30 PM', '14:30'),
    ]) {
      expect(formatScheduleTime(time, use24HourTime: false), twelve);
      expect(formatScheduleTime(time, use24HourTime: true), twentyFour);
    }
  });

  test('persists the selected time format', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = TimeFormatController();
    await controller.load();
    expect(controller.value, false);
    await controller.setUse24HourTime(true);
    final restored = TimeFormatController();
    await restored.load();
    expect(restored.value, true);
    controller.dispose();
    restored.dispose();
  });
}
