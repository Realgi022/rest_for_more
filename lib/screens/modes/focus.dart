import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int selectedMinutes = 20;

  Duration remaining = Duration.zero;

  Timer? _timer;
  DateTime? _endTime;

  bool isRunning = false;
  bool isPaused = false;

  void startTimer() {
    remaining = Duration(minutes: selectedMinutes);
    _startCountdown();
  }

  void _startCountdown() {
    _endTime = DateTime.now().add(remaining);

    setState(() {
      isRunning = true;
      isPaused = false;
    });

    NotificationService.showTimerNotification(remaining);

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final end = _endTime;

        if (end == null) return;

        final difference = end.difference(DateTime.now());

        if (difference <= Duration.zero) {
          finishTimer();
          return;
        }

        setState(() {
          remaining = difference;
        });
      },
    );
  }

  void pauseTimer() {
    if (_endTime != null) {
      remaining = _endTime!.difference(DateTime.now());
    }

    _timer?.cancel();
    _endTime = null;

    NotificationService.cancelTimerNotification();

    setState(() {
      isRunning = false;
      isPaused = true;
    });
  }

  void resumeTimer() {
    _startCountdown();
  }

  void finishTimer() {
    _timer?.cancel();
    _endTime = null;

    NotificationService.cancelTimerNotification();

    setState(() {
      remaining = Duration.zero;
      isRunning = false;
      isPaused = false;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _endTime = null;

    NotificationService.cancelTimerNotification();

    setState(() {
      remaining = Duration.zero;
      isRunning = false;
      isPaused = false;
    });
  }

  Future<void> confirmStop() async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Stop focus mode?'),
          content: const Text(
            'Your current timer will be cancelled.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Stop'),
            ),
          ],
        );
      },
    );

    if (shouldStop == true) {
      stopTimer();
    }
  }

  String formatTime(Duration duration) {
    final hours = duration.inHours;

    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerStarted = isRunning || isPaused;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!timerStarted) ...[
              Text(
                '$selectedMinutes minutes',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Slider(
                min: 5,
                max: 120,
                divisions: 23,
                value: selectedMinutes.toDouble(),
                label: '$selectedMinutes min',
                onChanged: (value) {
                  setState(() {
                    selectedMinutes = value.round();
                  });
                },
              ),

              const SizedBox(height: 30),

              FilledButton.icon(
                onPressed: startTimer,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              ),
            ],

            if (timerStarted) ...[
              Text(
                isPaused ? 'Paused' : 'Focus time remaining',
              ),

              const SizedBox(height: 10),

              Text(
                formatTime(remaining),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              if (isRunning)
                FilledButton.icon(
                  onPressed: pauseTimer,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),

              if (isPaused)
                FilledButton.icon(
                  onPressed: resumeTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume'),
                ),

              const SizedBox(height: 10),

              TextButton.icon(
                onPressed: confirmStop,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}