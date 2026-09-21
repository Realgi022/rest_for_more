import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: settings,
    );

    // Ask Android 13+ for notification permission
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showTimerNotification(Duration duration) async {
    final endTime = DateTime.now().add(duration);

    final androidDetails = AndroidNotificationDetails(
      'active_timer',
      'Active timer',
      channelDescription: 'Shows the currently running timer',
      importance: Importance.max,
      priority: Priority.max,

      // Keep notification visible
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,

      // Android timer countdown
      when: endTime.millisecondsSinceEpoch,
      usesChronometer: true,
      chronometerCountDown: true,

      // Automatically remove notification when timer reaches 0
      timeoutAfter: duration.inMilliseconds,
    );

    await _notifications.show(
      id: 1001,
      title: 'Focus mode active',
      body: 'Time remaining',
      notificationDetails: NotificationDetails(
        android: androidDetails,
      ),
    );
  }

  static Future<void> cancelTimerNotification() async {
    await _notifications.cancel(id: 1001);
  }
}