import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rest_for_more/screens/modes/mode_moment_detail.dart'
    show
        ModeScheduleChecklist,
        ModeScheduleSummaryTile,
        formatEndTime,
        formatRemaining;
import 'package:rest_for_more/services/timer_service.dart';

import '../localization/app_language.dart';
import '../models/mode_schedule.dart';
import '../services/mode_schedule_service.dart';
import '../controllers/time_format_controller.dart';
import '../theme/app_spacing.dart';
import 'progress.dart' show TodayActivity;

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date =
        '${_days[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]}';
    final muted = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.6);

    return ListenableBuilder(
      listenable: Listenable.merge([modeScheduleService, timeFormatController]),
      builder: (context, _) {
        final schedules = modeScheduleService.schedulesForDay(now);
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.15)),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    16,
                    AppSpacing.gutter,
                    24,
                  ),
                  children: [
                    MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaler: TextScaler.noScaling),
                      child: Text(
                        'Today',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: muted),
                    ),
                    const SizedBox(height: 20),
                    const _ActiveFocusCard(),
                    const TodayActivity(),
                    if (schedules.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Scheduled timers',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 12),
                      ...schedules.map(
                        (schedule) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TodayScheduleTile(schedule: schedule),
                        ),
                      ),
                    ],
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

class _TodayScheduleTile extends StatefulWidget {
  final ModeSchedule schedule;

  const _TodayScheduleTile({required this.schedule});

  @override
  State<_TodayScheduleTile> createState() => _TodayScheduleTileState();
}

class _TodayScheduleTileState extends State<_TodayScheduleTile> {
  Listenable? _router;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    _router = GoRouter.of(context).routerDelegate;
    _router!.addListener(_closeOverviewOnRouteChange);
  }

  @override
  void dispose() {
    _router?.removeListener(_closeOverviewOnRouteChange);
    super.dispose();
  }

  void _closeOverviewOnRouteChange() {
    if (!_sheetOpen || !mounted) return;
    _sheetOpen = false;
    Navigator.of(context).pop();
  }

  Future<void> _openDetails(BuildContext context) async {
    _sheetOpen = true;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _TodayScheduleDetails(schedule: widget.schedule),
    );
    _sheetOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return ModeScheduleSummaryTile(
      schedule: widget.schedule,
      onTap: () => _openDetails(context),
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
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ended
                                ? context.t.done
                                : formatRemaining(timer.remaining),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            status,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
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

class _TodayScheduleDetails extends StatelessWidget {
  final ModeSchedule schedule;

  const _TodayScheduleDetails({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = TimeOfDay(
      hour: schedule.startTimeMinutes ~/ 60,
      minute: schedule.startTimeMinutes % 60,
    );
    final end = TimeOfDay(
      hour: schedule.endTimeMinutes ~/ 60,
      minute: schedule.endTimeMinutes % 60,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(schedule.name, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              context.t.modeName(schedule.modeId.value),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(
                '${formatScheduleTime(start, use24HourTime: timeFormatController.value)} - '
                '${formatScheduleTime(end, use24HourTime: timeFormatController.value)}',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 26),
              ),
            ),
            const Divider(),
            const SizedBox(height: 12),
            ModeScheduleChecklist(
              schedule: schedule,
              occurrenceKey:
                  modeScheduleService.activeOccurrenceKey(
                    schedule,
                    DateTime.now(),
                  ) ??
                  modeScheduleService.occurrenceKeyForDate(
                    schedule,
                    DateTime.now(),
                  ),
              interactive: modeScheduleService.isActive(
                schedule,
                DateTime.now(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              schedule.repeatWeekly
                  ? '${context.t.repeatWeekly}: ${_weekdayNames(context, schedule)}'
                  : '${context.t.chosenCalendarDates}: ${_dateNames(context, schedule)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayNames(BuildContext context, ModeSchedule schedule) {
    return schedule.weekdays
        .map((weekday) => context.t.weekdayShort[weekday - 1])
        .join(', ');
  }

  String _dateNames(BuildContext context, ModeSchedule schedule) {
    final grouped = <String, List<int>>{};

    for (final value in schedule.dates) {
      final parts = value.split('-');
      if (parts.length != 3) continue;

      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year == null || month == null || day == null) continue;

      final key = '$year-$month';
      grouped.putIfAbsent(key, () => []).add(day);
    }

    final groups = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return groups
        .map((entry) {
          final parts = entry.key.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final days = [...entry.value]..sort();
          return '${days.join(', ')} ${context.t.monthsShort[month - 1]} $year';
        })
        .join(' • ');
  }
}
