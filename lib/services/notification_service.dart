import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../controllers/app_language.dart';
import '../localization/app_language.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const _completionId = 1002;
  static bool _initialized = false;
  static Future<void>? _completionWork;
  static AndroidScheduleMode? _completionScheduleMode;
  static bool _requestedPermission = false;

  static bool get supportsTimerAlerts =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> _initialize() async {
    const androidSettings = AndroidInitializationSettings(
      'ic_timer_notification',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings: settings);
  }

  static AndroidFlutterLocalNotificationsPlugin get _android => _notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()!;

  static NotificationDetails _completionDetails(AppStrings t) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          'focus_timer_complete',
          t.timerCompletionNotifications,
          importance: Importance.high,
          priority: Priority.high,
          onlyAlertOnce: true,
        ),
      );

  // Serialize updates to the same notification ID when the timer is toggled
  // quickly. Timer state should never depend on the notification plugin.
  static Future<void> _updateCompletion(Future<void> Function() update) {
    if (!supportsTimerAlerts) {
      return Future.value();
    }
    final work = (_completionWork ?? Future<void>.value()).then((_) async {
      try {
        if (!_initialized) {
          await _initialize();
          _initialized = true;
        }
        await update();
      } catch (error) {
        debugPrint('Focus timer notification: $error');
      }
    });
    _completionWork = work;
    return work.whenComplete(() {
      if (identical(_completionWork, work)) _completionWork = null;
    });
  }

  static Future<void> requestExactTimerAlerts() async {
    if (!supportsTimerAlerts) return;
    try {
      if (!(await _android.canScheduleExactNotifications() ?? false)) {
        await _android.requestExactAlarmsPermission();
      }
    } catch (error) {
      debugPrint('Exact timer alert permission: $error');
    }
  }

  static Future<void> _requestPermission() async {
    try {
      await _android.requestNotificationsPermission();
    } catch (error) {
      debugPrint('Focus timer notification permission: $error');
    }
  }

  static Future<void> scheduleTimerCompletion(DateTime endTime) =>
      _updateCompletion(() async {
        _completionScheduleMode = null;
        await _notifications.cancel(id: _completionId);
        if (!_requestedPermission) {
          _requestedPermission = true;
          unawaited(_requestPermission());
        }

        final t = AppStrings(appLanguageController.value);
        // The Android plugin truncates the timestamp to whole seconds.
        // Round up so the alert never appears before the timer reaches zero.
        const microsPerSecond = Duration.microsecondsPerSecond;
        final deadline = endTime.microsecondsSinceEpoch;
        final scheduledDate = tz.TZDateTime.from(
          DateTime.fromMicrosecondsSinceEpoch(
            ((deadline + microsPerSecond - 1) ~/ microsPerSecond) *
                microsPerSecond,
            isUtc: true,
          ),
          tz.UTC,
        );
        Future<void> schedule(AndroidScheduleMode mode) async {
          if (!scheduledDate.isAfter(DateTime.now())) return;
          await _notifications.zonedSchedule(
            id: _completionId,
            title: t.focusTimer,
            body: t.timerEnded,
            scheduledDate: scheduledDate,
            notificationDetails: _completionDetails(t),
            androidScheduleMode: mode,
          );
          _completionScheduleMode = mode;
        }

        if (await _android.canScheduleExactNotifications() ?? false) {
          try {
            await schedule(AndroidScheduleMode.exactAllowWhileIdle);
            return;
          } on PlatformException catch (error) {
            // Access can be revoked between checking and scheduling.
            if (error.code != 'exact_alarms_not_permitted') rethrow;
          }
        }
        await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
      });

  static Future<void> cancelTimerCompletion() => _updateCompletion(() async {
    await _notifications.cancel(id: _completionId);
    _completionScheduleMode = null;
  });

  static Future<void> notifyTimerCompleted() => _updateCompletion(() async {
    if (_completionScheduleMode == AndroidScheduleMode.exactAllowWhileIdle) {
      return; // Android delivers the exact alarm even when Flutter is paused.
    }

    if (_completionScheduleMode != null) {
      // If the inexact alarm has already fired, don't post a second alert.
      final pending = await _notifications.pendingNotificationRequests();
      if (!pending.any((request) => request.id == _completionId)) return;
      await _notifications.cancel(id: _completionId);
    }
    _completionScheduleMode = null;
    final t = AppStrings(appLanguageController.value);
    await _notifications.show(
      id: _completionId,
      title: t.focusTimer,
      body: t.timerEnded,
      notificationDetails: _completionDetails(t),
    );
  });

  // RUNNING TIMER
  static Future<void> showTimerNotification(Duration duration) async {
    final endTime = DateTime.now().add(duration);
    final t = AppStrings(appLanguageController.value);

    final androidDetails = AndroidNotificationDetails(
      'active_timer',
      t.activeTimer,
      channelDescription: t.activeTimerDescription,

      importance: Importance.high,
      priority: Priority.high,

      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,

      when: endTime.millisecondsSinceEpoch,
      usesChronometer: true,
      chronometerCountDown: true,

      timeoutAfter: duration.inMilliseconds,

      actions: [
        AndroidNotificationAction(
          'pause_timer',
          t.pause,
          showsUserInterface: true,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'stop_timer',
          t.stop,
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    await _notifications.show(
      id: 1001,
      title: t.focusTimer,
      body: t.timerDuration(_formatTime(duration)),
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  // PAUSED TIMER
  static Future<void> showPausedTimerNotification(Duration remaining) async {
    final t = AppStrings(appLanguageController.value);

    final androidDetails = AndroidNotificationDetails(
      'active_timer',
      t.activeTimer,
      channelDescription: t.activeTimerDescription,

      importance: Importance.low,
      priority: Priority.low,

      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      silent: true,

      category: AndroidNotificationCategory.alarm,

      actions: [
        AndroidNotificationAction(
          'resume_timer',
          t.resume,
          showsUserInterface: true,
          cancelNotification: false,
        ),

        AndroidNotificationAction(
          'stop_timer',
          t.stop,
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    await _notifications.show(
      id: 1001,
      title: _formatTime(remaining),
      body: t.timerPaused,
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> cancelTimerNotification() async {
    await _notifications.cancel(id: 1001);
  }

  static String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }
}
