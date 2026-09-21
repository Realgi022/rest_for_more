import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize({
    required void Function(NotificationResponse response) onAction,
  }) async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onAction,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // RUNNING TIMER
  static Future<void> showTimerNotification(Duration duration) async {
    final endTime = DateTime.now().add(duration);

    final androidDetails = AndroidNotificationDetails(
      'active_timer',
      'Active timer',
      channelDescription: 'Shows the currently running timer',

      importance: Importance.high,
      priority: Priority.high,

      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,

      when: endTime.millisecondsSinceEpoch,
      usesChronometer: true,
      chronometerCountDown: true,

      timeoutAfter: duration.inMilliseconds,

      actions: const [
        AndroidNotificationAction(
          'pause_timer',
          'Pause',
          showsUserInterface: true,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'stop_timer',
          'Stop',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    await _notifications.show(
      id: 1001,
      title: 'Focus timer',
      body: 'Timer ${_formatTime(duration)}',
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  // PAUSED TIMER
  static Future<void> showPausedTimerNotification(Duration remaining) async {
    final androidDetails = AndroidNotificationDetails(
      'active_timer',
      'Active timer',
      channelDescription: 'Shows the currently running timer',

      importance: Importance.low,
      priority: Priority.low,

      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      silent: true,

      category: AndroidNotificationCategory.alarm,

      actions: const [
        AndroidNotificationAction(
          'resume_timer',
          'Resume',
          showsUserInterface: true,
          cancelNotification: false,
        ),

        AndroidNotificationAction(
          'stop_timer',
          'Stop',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    await _notifications.show(
      id: 1001,
      title: _formatTime(remaining),
      body: 'Timer paused',
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
