import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/timer_service.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  String formatTime(Duration duration) {
    final hours = duration.inHours;

    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  Future<void> confirmStop(BuildContext context) async {
    final timer = FocusTimerService.instance;

    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Stop focus mode?'),
          content: const Text('Your current timer will be cancelled.'),
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
      timer.stopTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timer = FocusTimerService.instance;

    return ListenableBuilder(
      listenable: timer,
      builder: (context, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.go('/modes');
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),

                    const SizedBox(width: 8),

                    Text('Focus', style: theme.textTheme.headlineMedium),
                  ],
                ),

                const SizedBox(height: 24),

                if (!timer.timerStarted) _TimerSetupCard(timer: timer),

                if (timer.timerStarted)
                  _ActiveTimerCard(
                    timer: timer,
                    formattedTime: formatTime(timer.remaining),
                    onStop: () => confirmStop(context),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerSetupCard extends StatelessWidget {
  final FocusTimerService timer;

  const _TimerSetupCard({required this.timer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus timer', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Choose how long you want to focus.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(
            '${timer.selectedMinutes} min',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Slider(
            min: 5,
            max: 120,
            divisions: 23,
            value: timer.selectedMinutes.toDouble(),
            label: '${timer.selectedMinutes} min',
            onChanged: (value) {
              timer.setMinutes(value.round());
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: timer.startTimer,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start focus'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTimerCard extends StatelessWidget {
  final FocusTimerService timer;
  final String formattedTime;
  final VoidCallback onStop;

  const _ActiveTimerCard({
    required this.timer,
    required this.formattedTime,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  timer.isPaused ? Icons.pause : Icons.timer_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timer.isPaused ? 'Focus paused' : 'Focus active',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timer.isPaused
                          ? 'Resume when you are ready.'
                          : 'Stay focused until the timer ends.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Text(
            formattedTime,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            timer.isPaused ? 'Paused' : 'Time remaining',
            style: theme.textTheme.bodySmall,
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: timer.isRunning
                ? FilledButton.icon(
                    onPressed: timer.pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  )
                : FilledButton.icon(
                    onPressed: timer.resumeTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                  ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onStop,
              icon: const Icon(Icons.stop_outlined),
              label: const Text('Stop focus'),
            ),
          ),
        ],
      ),
    );
  }
}
