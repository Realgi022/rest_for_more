import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_language.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final today = DateTime.now();
    final weekdays = t.weekdayShort;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: ListView(
          children: [
            Row(
              children: [
                Text(t.thisWeeksMoments),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    context.go('/calendar');
                  },
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final day in weekdays) Text(day),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(t.today, style: appTextTheme.headlineMedium),
                const Spacer(),
                Text(
                  today.toString().substring(0, 10),
                  style: appTextTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(t.completedMoments, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.10),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Text(t.morningMoment, style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  Text('25 min', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(t.stepCompleted, style: theme.textTheme.headlineMedium),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.go('/all-steps');
                  },
                  child: Text(t.seeAllSteps),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.gutter),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text(t.todaysStep, style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Text(t.day8, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.waterStepDone,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
