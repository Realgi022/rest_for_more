import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rest_for_more/services/timer_service.dart';

void main() {
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final timer = FocusTimerService.instance;
  final calls = <MethodCall>[];
  var exactAllowed = true;
  Map<String, Object?>? pending;

  void expectSchedule(String mode) {
    final call = calls.last;
    expect(call.method, 'zonedSchedule');
    expect(call.arguments['body'], 'The timer has ended');
    expect(call.arguments['platformSpecifics']['scheduleMode'], mode);
    expect(pending, isNotNull);
  }

  setUp(() {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();
    pending = null;
    exactAllowed = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'initialize':
            case 'requestNotificationsPermission':
              return true;
            case 'canScheduleExactNotifications':
              return exactAllowed;
            case 'zonedSchedule':
              pending = {
                'id': call.arguments['id'],
                'title': call.arguments['title'],
                'body': call.arguments['body'],
              };
            case 'pendingNotificationRequests':
              return [?pending];
            case 'cancel':
              pending = null;
          }
          return null;
        });
  });

  testWidgets(
    'starting and resuming schedule an alert; pausing and stopping cancel it',
    (tester) async {
      timer.setSeconds(30);
      timer.startTimer();
      await tester.pump();
      expectSchedule('exactAllowWhileIdle');

      timer.pauseTimer();
      await tester.pump();
      expect(pending, isNull);

      timer.resumeTimer();
      await tester.pump();
      expectSchedule('exactAllowWhileIdle');

      timer.cancelTimer();
      await tester.pump();
      expect(pending, isNull);
      expect(calls.where((call) => call.method == 'show'), isEmpty);
    },
  );

  testWidgets('completion does not duplicate the exact Android alarm', (
    tester,
  ) async {
    timer.startWithDuration(const Duration(seconds: 30));
    await tester.pump();
    expectSchedule('exactAllowWhileIdle');

    unawaited(timer.finishTimer());
    await tester.pump(const Duration(seconds: 5));
    expect(pending, isNotNull);
    expect(calls.where((call) => call.method == 'show'), isEmpty);
  });

  testWidgets('completion replaces an inexact alert that is still pending', (
    tester,
  ) async {
    exactAllowed = false;
    timer.startWithDuration(const Duration(seconds: 30));
    await tester.pump();
    expectSchedule('inexactAllowWhileIdle');

    unawaited(timer.finishTimer());
    await tester.pump(const Duration(seconds: 5));
    expect(pending, isNull);
    final show = calls.singleWhere((call) => call.method == 'show');
    expect(show.arguments['body'], 'The timer has ended');
  });

  testWidgets('completion does not repeat an inexact alert already delivered', (
    tester,
  ) async {
    exactAllowed = false;
    timer.startWithDuration(const Duration(seconds: 30));
    await tester.pump();
    expectSchedule('inexactAllowWhileIdle');
    pending = null; // Android delivered the background alert.

    unawaited(timer.finishTimer());
    await tester.pump(const Duration(seconds: 5));
    expect(calls.where((call) => call.method == 'show'), isEmpty);
  });
}
