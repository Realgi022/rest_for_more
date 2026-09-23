import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_blocker/app_blocker.dart';

import 'notification_service.dart';

class FocusTimerService extends ChangeNotifier {
  FocusTimerService._();

  static final FocusTimerService instance = FocusTimerService._();

  final AppBlocker _blocker = AppBlocker.instance;

  int selectedMinutes = 20;

  Duration remaining = Duration.zero;

  Timer? _timer;
  DateTime? _endTime;

  bool isRunning = false;
  bool isPaused = false;

  bool get timerStarted => isRunning || isPaused;

  void setMinutes(int minutes) {
    selectedMinutes = minutes;
    notifyListeners();
  }

  void startTimer() {
    remaining = Duration(minutes: selectedMinutes);
    _startCountdown();
  }

  void _startCountdown() {
    _endTime = DateTime.now().add(remaining);

    isRunning = true;
    isPaused = false;

    NotificationService.showTimerNotification(remaining);

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final end = _endTime;

      if (end == null) return;

      final difference = end.difference(DateTime.now());

      if (difference <= Duration.zero) {
        finishTimer(); 
        return;
      }

      remaining = difference;
      NotificationService.showTimerNotification(remaining);

      notifyListeners();
    });

    notifyListeners();
  }

  void pauseTimer() {
    if (_endTime != null) {
      remaining = _endTime!.difference(DateTime.now());
    }

    _timer?.cancel();
    _endTime = null;

    isRunning = false;
    isPaused = true;

    NotificationService.showPausedTimerNotification(remaining);

    notifyListeners();
  }

  void resumeTimer() {
    _startCountdown();
  }

  void finishTimer() async {
    _timer?.cancel();
    _endTime = null;
    _blocker.unblockAll();

    NotificationService.cancelTimerNotification();

    remaining = Duration.zero;
    isRunning = false;
    isPaused = false;

    notifyListeners();
  }

  void stopTimer() async {
    _timer?.cancel();
    _endTime = null;
    _blocker.unblockAll();

    NotificationService.cancelTimerNotification();

    remaining = Duration.zero;
    isRunning = false;
    isPaused = false;

    notifyListeners();
  }
}
