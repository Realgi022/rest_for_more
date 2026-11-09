import 'package:flutter/material.dart';

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
                const TodayActivity(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
