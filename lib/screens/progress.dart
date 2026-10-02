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
      body: Column(
        children: [
          Text ("This week's moments"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Mo'),
              Text('Tu'),
              Text('We'),
              Text('Th'),
              Text('Fr'),
              Text('Sa'),
              Text('Su'),
              Spacer(),
              IconButton(
                onPressed: () {
                  context.go('/calendar');
                },
                icon: Icon(Icons.calendar_month),
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
          Text('Completed moments', style: appTextTheme.headlineSmall),
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
                Icon(Icons.wb_sunny_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Text('Morning',
                style: theme.textTheme.bodyMedium),
                Spacer(),
                Text('25 min'
                , style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                'Step completed', 
                style: appTextTheme.headlineSmall,
                ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.go('/allSteps');
                },
                child: Text('See all steps'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
