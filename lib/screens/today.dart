import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rest_for_more/localization/app_language.dart';
import 'package:rest_for_more/screens/modes/focus_moment_detail.dart'
    show formatEndTime, formatRemaining;
import 'package:rest_for_more/services/timer_service.dart';

import 'progress.dart' show TodayActivity;

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = '${_days[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]}';
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.15)),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.noScaling),
                  child: Text('Today',
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
                const SizedBox(height: 4),
                Text(date,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: muted)),
                const SizedBox(height: 20),
                const _ActiveFocusCard(),
                const TodayActivity(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveFocusCard extends StatelessWidget {
  const _ActiveFocusCard();

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;

    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) {
        if (!timer.timerStarted) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final muted = scheme.onSurface.withValues(alpha: 0.6);
        final ended = timer.hasEnded;

        final status = ended
            ? context.t.timerEnded
            : timer.isPaused
                ? 'Paused'
                : 'Ends at ${formatEndTime(DateTime.now().add(timer.remaining))}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: theme.cardTheme.color ?? scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.go('/modes/focus'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 14, 16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.primary, width: 2),
                      ),
                      child: Icon(
                        timer.isPaused ? Icons.pause : Icons.timer_outlined,
                        color: scheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t.focus,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: muted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ended
                                ? context.t.done
                                : formatRemaining(timer.remaining),
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            status,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: muted),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: muted),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
