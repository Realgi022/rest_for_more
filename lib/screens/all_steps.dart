import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../theme/app_card.dart';
import '../theme/app_spacing.dart';
import '../data/repository/plan_repository.dart';
import '../models/completed_steps.dart';

class AllStepsScreen extends StatefulWidget {
  const AllStepsScreen({super.key});

  @override
  State<AllStepsScreen> createState() => _AllStepsScreenState();
}

class _AllStepsScreenState extends State<AllStepsScreen> {
  DateTime selectedMonth = DateTime.now();

  List<CompletedStep> completedSteps = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedSteps();
  }

  Future<void> _loadCompletedSteps() async {
    final steps = await PlanRepository.loadCompletedSteps();

    if (!mounted) return;

    setState(() {
      completedSteps = steps;
    });
  }

  void previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void nextMonth() {
    if (isCurrentMonth) return;

    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  bool get isCurrentMonth {
    final now = DateTime.now();

    return selectedMonth.year == now.year && selectedMonth.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;

    // Month names automatically change between NL and EN.
    final monthLabel =
        '${t.months[selectedMonth.month - 1]} ${selectedMonth.year}';

    final monthlySteps = completedSteps.where((step) {
      return step.completedAt.year == selectedMonth.year &&
          step.completedAt.month == selectedMonth.month;
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
                    Image.asset('assets/Icon moon.png', width: 24, height: 24),

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
                            TextSpan(text: t.completeFirstStepOfMonth),
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
                        const SizedBox(height: AppSpacing.xxl),

                    itemBuilder: (context, index) {
                      final step = monthlySteps[index];
                      final date = step.completedAt;

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: appCardDecoration(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline),

                                const SizedBox(width: AppSpacing.sm),

                                Expanded(
                                  child: Text(
                                    step.title,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),

                                const SizedBox(width: AppSpacing.sm),

                                Text(
                                  '${date.day}-${date.month}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.md),

                            Divider(
                              height: 1,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.2,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.md),

                            Text(
                              step.description,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
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
