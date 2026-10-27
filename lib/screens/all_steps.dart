import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AllStepsScreen extends StatefulWidget {
  const AllStepsScreen({super.key});

  @override
  State<AllStepsScreen> createState() => _AllStepsScreenState();
}

class _AllStepsScreenState extends State<AllStepsScreen> {
  DateTime selectedMonth = DateTime.now();

  void previousMonth() {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month - 1,
      );
    });
  }

  void nextMonth() {
    final currentMonth = DateTime.now();

    final isCurrentMonth =
        selectedMonth.year == currentMonth.year &&
        selectedMonth.month == currentMonth.month;

    if (isCurrentMonth) return;

    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
      );
    });
  }

  bool get isCurrentMonth {
    final now = DateTime.now();

    return selectedMonth.year == now.year &&
        selectedMonth.month == now.month;
  }

  String get monthLabel {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[selectedMonth.month - 1]} ${selectedMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completed steps',
                style: theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: AppSpacing.xl),

              Row(
                children: [
                  IconButton(
                    onPressed: previousMonth,
                    icon: const Icon(Icons.chevron_left),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        monthLabel,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: isCurrentMonth ? null : nextMonth,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Moon image'
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  Text(
                    'Go to Today and complete your first step of the month.',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              Container(
                width: double.infinity,
                height: 1,
                color: theme.colorScheme.onSurface,
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                "Track your completed steps here.",
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}