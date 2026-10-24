import 'dart:async';
import 'package:flutter/material.dart';

class FocusTimerService extends ChangeNotifier {
  FocusTimerService._();

  static final FocusTimerService instance = FocusTimerService._();

  int selectedHours = 0;
  int selectedMinutes = 0;
  int selectedSeconds = 0;

  Duration remaining = Duration.zero;
  Duration endTime = Duration.zero;

  Timer? _timer;
  DateTime? _endTime;

  bool isRunning = false;
  bool isPaused = false;
  bool hasEnded = false;

  bool get timerStarted => isRunning || isPaused;

  Duration get selectedDuration {
    return Duration(
      hours: selectedHours,
      minutes: selectedMinutes,
      seconds: selectedSeconds,
    );
  }

  void setHours(int hours) {
    selectedHours = hours;
    notifyListeners();
  }

  void setMinutes(int minutes) {
    selectedMinutes = minutes;
    notifyListeners();
  }

  void setSeconds(int seconds) {
    selectedSeconds = seconds;
    notifyListeners();
  }

  void setDuration({
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    selectedHours = hours;
    selectedMinutes = minutes;
    selectedSeconds = seconds;

    notifyListeners();
  }

  void startTimer() {
    final duration = selectedDuration;

    if (duration <= Duration.zero) {
      return;
    }

    remaining = duration;

    _startCountdown();
  }

  void _startCountdown() {
    _endTime = DateTime.now().add(remaining);

    isRunning = true;
    isPaused = false;

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) {
        final end = _endTime;

        if (end == null) return;

        final difference = end.difference(DateTime.now());

        if (difference <= Duration.zero) {
          remaining = Duration.zero;
          finishTimer();
          return;
        }

        remaining = difference;

        notifyListeners();
      },
    );

    notifyListeners();
  }

  void pauseTimer() {
    if (_endTime != null) {
      remaining = _endTime!.difference(DateTime.now());

      if (remaining < Duration.zero) {
        remaining = Duration.zero;
      }
    }

    _timer?.cancel();
    _endTime = null;

    isRunning = false;
    isPaused = true;

    notifyListeners();
  }

  void resumeTimer() {
    if (!isPaused || remaining <= Duration.zero) {
      return;
    }

    _startCountdown();
  }

  Future<void> finishTimer() async {
    _timer?.cancel();
    _endTime = null;

    remaining = Duration.zero;

    hasEnded = true;

    notifyListeners();

    await Future.delayed(const Duration(seconds: 5));

    isRunning = false;
    isPaused = false;
    hasEnded = false;

    notifyListeners();
  }

  void cancelTimer() {
    _timer?.cancel();
    _endTime = null;

        remaining = Duration.zero;

    isRunning = false;
    isPaused = false;
    hasEnded = false;

    notifyListeners();
  }
}