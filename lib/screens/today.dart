import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../models/mode_schedule.dart';
import '../services/mode_schedule_service.dart';
import '../services/time_format_controller.dart';
import '../theme/app_spacing.dart';
import 'progress.dart' show TodayActivity;

TimeOfDay _scheduleTime(int minutes) =>
    TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

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

class _TodayScheduleTile extends StatelessWidget {
  final ModeSchedule schedule;

  const _TodayScheduleTile({required this.schedule});

  void _openDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _TodayScheduleDetails(schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _openDetails(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.schedule, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(schedule.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    context.t.modeName(schedule.modeId.value),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatScheduleTime(_scheduleTime(schedule.startTimeMinutes), use24HourTime: timeFormatController.value)} - '
                    '${formatScheduleTime(_scheduleTime(schedule.endTimeMinutes), use24HourTime: timeFormatController.value)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, size: 20),
          ],
        ),
      ),
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
              ),
            ),
            const Divider(),
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
