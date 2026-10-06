import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: ListView(
          children: [
            Row(
              children: [
                Text("This week's moments"),
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
                      Text('Mo'),
                      Text('Tu'),
                      Text('We'),
                      Text('Th'),
                      Text('Fr'),
                      Text('Sa'),
                      Text('Su'),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('Today', style: appTextTheme.headlineMedium),
                Spacer(),
                Text(
                  today.toString().substring(0, 10),
                  style: appTextTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Completed moments', style: theme.textTheme.headlineMedium),
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
                  Text('Morning', style: theme.textTheme.bodyMedium),
                  Spacer(),
                  Text('25 min', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Step completed', style: theme.textTheme.headlineMedium),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.go('/allSteps');
                  },
                  child: Text('See all steps'),
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
                        Icons.wb_sunny_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text("Today's step", style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Text('Day 8', style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You drank 8 glasses of water today, great job!',
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
