
import 'package:flutter/material.dart';

import '../localization/app_language.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;

    // Month names automatically change between NL and EN.
    final monthLabel =
        '${t.months[selectedMonth.month - 1]} ${selectedMonth.year}';

    // Placeholder data - replace with actual completed steps later.
    // Kept inside build so descriptions update when language changes.
    final completedSteps = <Map<String, dynamic>>[
      {
        'icon': const Icon(Icons.water_drop),
        'title': t.stepNumber(3),
        'date': DateTime.now(),
        'description': t.waterStepDone,
      },
      {
        'icon': const Icon(Icons.chair),
        'title': t.stepNumber(2),
        'description': t.prepareForRestfulNight,
        'date': DateTime(2026, 9, 25),
      },
      {
        'icon': const Icon(Icons.directions_walk),
        'title': t.stepNumber(1),
        'description': t.walkOutsideFor15Minutes,
        'date': DateTime(2026, 9, 21),
      },
    ];

    final monthlySteps = completedSteps.where((step) {
      final date = step['date'] as DateTime;

      return date.year == selectedMonth.year &&
          date.month == selectedMonth.month;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.completedStepsTitle,
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

              if (monthlySteps.isEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/Icon moon.png',
                      width: 24,
                      height: 24,
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          style: theme.textTheme.titleSmall,
                          children: [
                            TextSpan(text: t.goTo),
                            TextSpan(
                              text: t.today,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: t.completeFirstStepOfMonth,
                            ),
                          ],
                        ),
                      ),
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
                  t.trackCompletedStepsHere,
                  style: theme.textTheme.bodyMedium,
                ),
              ] else ...[
                Expanded(
                  child: ListView.separated(
                    itemCount: monthlySteps.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(
                          height: AppSpacing.xxl,
                        ),
                    itemBuilder: (context, index) {
                      final step = monthlySteps[index];
                      final date = step['date'] as DateTime;

                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              step['icon'] as Widget,

                              const SizedBox(
                                width: AppSpacing.sm,
                              ),

                              Expanded(
                                child: Text(
                                  step['title'] as String,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),

                              const SizedBox(
                                width: AppSpacing.sm,
                              ),

                              Text(
                                '${date.day}-${date.month}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          Divider(
                            height: 1,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.2),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          Text(
                            step['description'] as String,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
