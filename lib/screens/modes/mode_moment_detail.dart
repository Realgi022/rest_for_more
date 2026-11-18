import 'package:circle_time_progress/circle_time_progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rest_for_more/localization/app_language.dart';
import 'package:rest_for_more/models/mode_schedule.dart';
import 'package:rest_for_more/services/mode_schedule_service.dart';
import 'package:rest_for_more/services/timer_service.dart';
import 'package:rest_for_more/services/time_format_controller.dart';
import 'package:rest_for_more/services/week_start_controller.dart';

class ModeMomentScreen extends StatefulWidget {
  final ModeId modeId;

  const ModeMomentScreen({super.key, this.modeId = ModeId.focus});

  @override
  State<ModeMomentScreen> createState() => _ModeMomentScreenState();
}

class _ModeMomentScreenState extends State<ModeMomentScreen> {
  final timer = FocusTimerService.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([timer, timeFormatController]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(modeId: widget.modeId),
                  const SizedBox(height: 32),
                  _TimerCard(modeId: widget.modeId),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final ModeId modeId;

  const _Header({required this.modeId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.modeName(modeId.value),
          style: GoogleFonts.cormorantGaramond(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          context.t.modeMomentTimer(modeId.value),
          style: GoogleFonts.manrope(fontSize: 20),
        ),
      ],
    );
  }
}

class _TimerCard extends StatelessWidget {
  final ModeId modeId;

  const _TimerCard({required this.modeId});

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;

    return timer.timerStarted
        ? const _ActiveTimerCard()
        : Column(
            children: [
              const _InactiveTimerCard(),
              const SizedBox(height: 24),
              _ModeScheduleSection(modeId: modeId),
            ],
          );
  }
}

class _InactiveTimerCard extends StatefulWidget {
  const _InactiveTimerCard();

  @override
  State<_InactiveTimerCard> createState() => _InactiveTimerCardState();
}

class _InactiveTimerCardState extends State<_InactiveTimerCard> {
  final timer = FocusTimerService.instance;

  late final FixedExtentScrollController hoursController;
  late final FixedExtentScrollController minutesController;
  late final FixedExtentScrollController secondsController;

  @override
  void initState() {
    super.initState();

    hoursController = FixedExtentScrollController(
      initialItem: timer.selectedHours,
    );

    minutesController = FixedExtentScrollController(
      initialItem: timer.selectedMinutes,
    );

    secondsController = FixedExtentScrollController(
      initialItem: timer.selectedSeconds,
    );
  }

  @override
  void dispose() {
    hoursController.dispose();
    minutesController.dispose();
    secondsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _DurationsPicker(
            hoursController: hoursController,
            minutesController: minutesController,
            secondsController: secondsController,
          ),
          const SizedBox(height: 32),
          _TimerPresets(
            hoursController: hoursController,
            minutesController: minutesController,
            secondsController: secondsController,
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: timer.startTimer,
            child: Text(
              context.t.start,
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.normal,
                fontSize: 20,
              ),
            ),
          ),

          // ElevatedButton(
          //   onPressed: timer.startTimer,
          //   child: Text(
          //     'Start',
          //     textAlign: TextAlign.center,
          //     style: GoogleFonts.cormorantGaramond(
          //       color: theme.colorScheme.onPrimary,
          //       fontWeight: FontWeight.normal,
          //       fontSize: 20,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _DurationsPicker extends StatelessWidget {
  final FixedExtentScrollController hoursController;
  final FixedExtentScrollController minutesController;
  final FixedExtentScrollController secondsController;

  const _DurationsPicker({
    required this.hoursController,
    required this.minutesController,
    required this.secondsController,
  });

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _TimePickerColumn(
          label: context.t.hours,
          maxValue: 23,
          controller: hoursController,
          onChanged: timer.setHours,
        ),
        _TimePickerColumn(
          label: context.t.minutesLabel,
          maxValue: 59,
          controller: minutesController,
          onChanged: timer.setMinutes,
        ),
        _TimePickerColumn(
          label: context.t.seconds,
          maxValue: 59,
          controller: secondsController,
          onChanged: timer.setSeconds,
        ),
      ],
    );
  }
}

class _TimePickerColumn extends StatelessWidget {
  final String label;
  final int maxValue;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onChanged;

  const _TimePickerColumn({
    required this.label,
    required this.maxValue,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(label, style: GoogleFonts.manrope(color: colorScheme.onSurface)),

        const SizedBox(height: 8),

        SizedBox(
          width: 80,
          height: 150,
          child: CupertinoPicker(
            scrollController: controller,
            itemExtent: 40,
            onSelectedItemChanged: onChanged,
            selectionOverlay: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            children: List.generate(
              maxValue + 1,
              (index) => Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: GoogleFonts.manrope(color: colorScheme.onSurface),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeScheduleSection extends StatelessWidget {
  final ModeId modeId;

  const _ModeScheduleSection({required this.modeId});

  Future<void> _openScheduleForm(
    BuildContext context, {
    ModeSchedule? existingSchedule,
  }) async {
    final schedule = await showModalBottomSheet<_ScheduleFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _ScheduleFormSheet(modeId: modeId, schedule: existingSchedule);
      },
    );

    if (schedule == null) return;

    if (existingSchedule != null) {
      await modeScheduleService.updateSchedule(
        existingSchedule.copyWith(
          weekdays: schedule.weekdays,
          dates: schedule.dates,
          repeatWeekly: schedule.repeatWeekly,
          name: schedule.name,
          startTimeMinutes: schedule.startTimeMinutes,
          endTimeMinutes: schedule.endTimeMinutes,
        ),
      );
      return;
    }

    final added = await modeScheduleService.addSchedule(
      modeId: modeId,
      name: schedule.name,
      dates: schedule.dates,
      repeatWeekly: schedule.repeatWeekly,
      weekdays: schedule.weekdays,
      startTimeMinutes: schedule.startTimeMinutes,
      endTimeMinutes: schedule.endTimeMinutes,
    );
    if (!added && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.scheduleLimitMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: Listenable.merge([modeScheduleService, timeFormatController]),
      builder: (context, _) {
        final schedules = modeScheduleService.schedulesFor(modeId);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t.plannedMode(
                            context.t.modeName(modeId.value),
                          ),
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          context.t.chooseDaysAndTimeWindow,
                          style: GoogleFonts.manrope(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          context.t.schedulesCount(
                            schedules.length,
                            ModeScheduleService.maxSchedulesPerMode,
                          ),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (schedules.length <
                      ModeScheduleService.maxSchedulesPerMode)
                    IconButton(
                      onPressed: () => _openScheduleForm(context),
                      color: colorScheme.primary,
                      tooltip: context.t.addSchedule,
                      icon: const Icon(Icons.add),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (schedules.isEmpty)
                Text(
                  context.t.noSchedulesYet,
                  style: GoogleFonts.manrope(color: colorScheme.onSurface),
                )
              else
                ...schedules.map(
                  (schedule) => _ScheduleTile(
                    schedule: schedule,
                    onTap: () =>
                        _openScheduleForm(context, existingSchedule: schedule),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final ModeSchedule schedule;
  final VoidCallback onTap;

  const _ScheduleTile({required this.schedule, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.name,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatWeekdays(schedule.weekdays, context.t),
                      style: GoogleFonts.manrope(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatScheduleTime(_minutesToTimeOfDay(schedule.startTimeMinutes), use24HourTime: timeFormatController.value)} - '
                      '${formatScheduleTime(_minutesToTimeOfDay(schedule.endTimeMinutes), use24HourTime: timeFormatController.value)}',
                      style: GoogleFonts.manrope(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.t.tapToEdit,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: schedule.enabled,
                onChanged: (enabled) {
                  modeScheduleService.setEnabled(schedule.id, enabled);
                },
              ),
              IconButton(
                onPressed: () {
                  modeScheduleService.deleteSchedule(schedule.id);
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleFormSheet extends StatefulWidget {
  final ModeId modeId;
  final ModeSchedule? schedule;

  const _ScheduleFormSheet({required this.modeId, this.schedule});

  @override
  State<_ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<_ScheduleFormSheet> {
  late Set<int> _weekdays;
  late Set<String> _dates;
  late bool _repeatWeekly;
  late final TextEditingController _nameController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  int _weekPage = 1000;
  late DateTime _calendarDate;
  late final PageController _weekController;
  bool _calendarExpanded = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final schedule = widget.schedule;
    _nameController = TextEditingController(text: schedule?.name ?? '');
    _dates = schedule?.dates.toSet() ?? <String>{};
    _repeatWeekly = schedule?.repeatWeekly ?? true;
    _calendarDate = DateTime.now();
    _weekController = PageController(initialPage: _weekPage);

    if (schedule != null) {
      _weekdays = schedule.weekdays.toSet();
      _startTime = _minutesToTimeOfDay(schedule.startTimeMinutes);
      _endTime = _minutesToTimeOfDay(schedule.endTimeMinutes);
      return;
    }

    _weekdays = {now.weekday};
    _startTime = TimeOfDay(hour: now.hour, minute: 0);
    _endTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weekController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final selected = await _showScheduleTimePicker(
      context: context,
      title: context.t.startTime,
      initialTime: _startTime,
    );

    if (selected == null) return;

    setState(() {
      _startTime = selected;
    });
  }

  Future<void> _pickEndTime() async {
    final selected = await _showScheduleTimePicker(
      context: context,
      title: context.t.endTime,
      initialTime: _endTime,
    );

    if (selected == null) return;

    setState(() {
      _endTime = selected;
    });
  }

  void _toggleDate(DateTime date) {
    setState(() {
      if (_repeatWeekly) {
        final weekday = date.weekday;
        if (_weekdays.contains(weekday)) {
          _weekdays.remove(weekday);
        } else {
          _weekdays.add(weekday);
        }
      } else {
        final key = _dateKey(date);
        if (!_dates.remove(key)) _dates.add(key);
      }
    });
  }

  DateTime _weekStartForPage(int page) {
    final now = DateTime.now();
    final firstWeekday = weekStartController.value
        ? DateTime.sunday
        : DateTime.monday;
    final daysSinceWeekStart = (now.weekday - firstWeekday + 7) % 7;
    final thisWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: daysSinceWeekStart));
    return thisWeek.add(Duration(days: (page - 1000) * 7));
  }

  List<int> get _weekdayOrder {
    final firstWeekday = weekStartController.value
        ? DateTime.sunday
        : DateTime.monday;
    return List.generate(7, (index) => (firstWeekday + index - 1) % 7 + 1);
  }

  String _calendarSummary() {
    if (_dates.isEmpty) return context.t.chooseCalendarDates;

    final grouped = <String, List<int>>{};
    for (final value in _dates) {
      final parts = value.split('-');
      if (parts.length != 3) continue;

      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year == null || month == null || day == null) continue;

      grouped.putIfAbsent('$year-$month', () => []).add(day);
    }

    final groups = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final summary = groups
        .map((entry) {
          final parts = entry.key.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final days = [...entry.value]..sort();
          return '${days.join(', ')} ${context.t.monthsShort[month - 1]} $year';
        })
        .join(' • ');

    return '${context.t.chosenCalendarDates}: $summary';
  }

  Widget _calendarGrid(BuildContext context) {
    final monthStart = DateTime(_calendarDate.year, _calendarDate.month, 1);
    final firstWeekday = _weekdayOrder.first;
    final leadingDays = (monthStart.weekday - firstWeekday + 7) % 7;
    final daysInMonth = DateTime(
      _calendarDate.year,
      _calendarDate.month + 1,
      0,
    ).day;
    final cells = <Widget>[];

    for (var index = 0; index < leadingDays; index += 1) {
      cells.add(const SizedBox.shrink());
    }

    for (var day = 1; day <= daysInMonth; day += 1) {
      final date = DateTime(_calendarDate.year, _calendarDate.month, day);
      final selected = _dates.contains(_dateKey(date));
      final isToday = DateUtils.isSameDay(date, DateTime.now());
      cells.add(
        GestureDetector(
          onTap: _repeatWeekly
              ? null
              : () => setState(() {
                  final key = _dateKey(date);
                  if (!_dates.remove(key)) _dates.add(key);
                }),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : isToday
                    ? Theme.of(context).colorScheme.surface
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isToday
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
              ),
              child: Text(
                '$day',
                style: GoogleFonts.manrope(
                  color: selected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.2,
      children: [
        ..._weekdayOrder.map(
          (weekday) => Center(
            child: Text(
              context.t.weekdayShort[weekday - 1],
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ...cells,
      ],
    );
  }

  void _save() {
    final startTimeMinutes = _timeOfDayToMinutes(_startTime);
    final endTimeMinutes = _timeOfDayToMinutes(_endTime);

    if ((_repeatWeekly && _weekdays.isEmpty) ||
        (!_repeatWeekly && _dates.isEmpty)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t.chooseAtLeastOneDay)));
      return;
    }

    if (startTimeMinutes == endTimeMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.chooseDifferentStartEndTimes)),
      );
      return;
    }

    Navigator.pop(
      context,
      _ScheduleFormResult(
        name: _nameController.text,
        dates: _dates.toList()..sort(),
        repeatWeekly: _repeatWeekly,
        weekdays: _weekdays.toList()..sort(),
        startTimeMinutes: startTimeMinutes,
        endTimeMinutes: endTimeMinutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ListenableBuilder(
      listenable: Listenable.merge([timeFormatController, weekStartController]),
      builder: (context, _) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.schedule == null
                      ? context.t.planMode(
                          context.t.modeName(widget.modeId.value),
                        )
                      : context.t.editMode(
                          context.t.modeName(widget.modeId.value),
                        ),
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: context.t.scheduleName,
                    hintText: context.t.scheduleNameHint,
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.t.scheduleDaysTitle,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 78,
                        child: PageView.builder(
                          controller: _weekController,
                          itemBuilder: (context, page) {
                            final weekStart = _weekStartForPage(page);
                            return Row(
                              children: List.generate(7, (index) {
                                final date = weekStart.add(
                                  Duration(days: index),
                                );
                                final weekday = _weekdayOrder[index];
                                final selected = _repeatWeekly
                                    ? _weekdays.contains(weekday)
                                    : _dates.contains(_dateKey(date));
                                final isToday = DateUtils.isSameDay(
                                  date,
                                  DateTime.now(),
                                );
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _toggleDate(date),
                                    child: Column(
                                      children: [
                                        Text(
                                          context.t.weekdayShort[weekday - 1],
                                          style: GoogleFonts.manrope(
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 150,
                                          ),
                                          width: 38,
                                          height: 34,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.18)
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isToday
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                  : Colors.transparent,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '${date.day}',
                                            style: GoogleFonts.manrope(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                          onPageChanged: (page) => _weekPage = page,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: context.t.chooseCalendarDates,
                      onPressed: () => setState(() {
                        _calendarExpanded = !_calendarExpanded;
                      }),
                      icon: Icon(
                        _calendarExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.calendar_month_outlined,
                      ),
                    ),
                  ],
                ),
                if (_calendarExpanded)
                  IgnorePointer(
                    ignoring: _repeatWeekly,
                    child: Opacity(
                      opacity: _repeatWeekly ? 0.45 : 1,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _calendarSummary(),
                              style: GoogleFonts.manrope(fontSize: 13),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${context.t.months[_calendarDate.month - 1]} ${_calendarDate.year}',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() {
                                  _calendarDate = DateTime(
                                    _calendarDate.year,
                                    _calendarDate.month - 1,
                                    1,
                                  );
                                }),
                                icon: const Icon(Icons.chevron_left),
                              ),
                              IconButton(
                                onPressed: () => setState(() {
                                  _calendarDate = DateTime(
                                    _calendarDate.year,
                                    _calendarDate.month + 1,
                                    1,
                                  );
                                }),
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                          _calendarGrid(context),
                        ],
                      ),
                    ),
                  ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _repeatWeekly,
                  title: Text(context.t.repeatWeekly),
                  subtitle: Text(context.t.repeatWeeklyDescription),
                  onChanged: (value) => setState(() {
                    _repeatWeekly = value ?? true;
                    if (_repeatWeekly) _dates.clear();
                  }),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.play_arrow_outlined),
                  title: Text(context.t.from),
                  subtitle: Text(
                    formatScheduleTime(
                      _startTime,
                      use24HourTime: timeFormatController.value,
                    ),
                  ),
                  onTap: _pickStartTime,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.stop_outlined),
                  title: Text(context.t.to),
                  subtitle: Text(
                    formatScheduleTime(
                      _endTime,
                      use24HourTime: timeFormatController.value,
                    ),
                  ),
                  onTap: _pickEndTime,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(
                      widget.schedule == null
                          ? context.t.saveSchedule
                          : context.t.updateSchedule,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleFormResult {
  final String name;
  final List<String> dates;
  final bool repeatWeekly;
  final List<int> weekdays;
  final int startTimeMinutes;
  final int endTimeMinutes;

  const _ScheduleFormResult({
    required this.name,
    required this.dates,
    required this.repeatWeekly,
    required this.weekdays,
    required this.startTimeMinutes,
    required this.endTimeMinutes,
  });
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

Future<TimeOfDay?> _showScheduleTimePicker({
  required BuildContext context,
  required String title,
  required TimeOfDay initialTime,
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _ScrollableTimePickerSheet(title: title, initialTime: initialTime);
    },
  );
}

class _ScrollableTimePickerSheet extends StatefulWidget {
  final String title;
  final TimeOfDay initialTime;

  const _ScrollableTimePickerSheet({
    required this.title,
    required this.initialTime,
  });

  @override
  State<_ScrollableTimePickerSheet> createState() =>
      _ScrollableTimePickerSheetState();
}

class _ScrollableTimePickerSheetState
    extends State<_ScrollableTimePickerSheet> {
  late int _hour24;
  late int _minute;
  late bool _isPm;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late final FixedExtentScrollController _periodController;

  @override
  void initState() {
    super.initState();

    _hour24 = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _isPm = _hour24 >= 12;

    _hourController = FixedExtentScrollController(
      initialItem: timeFormatController.value
          ? _hour24
          : (_hour24 % 12 == 0 ? 11 : (_hour24 % 12) - 1),
    );
    _minuteController = FixedExtentScrollController(initialItem: _minute);
    _periodController = FixedExtentScrollController(initialItem: _isPm ? 1 : 0);
    timeFormatController.addListener(_onFormatChanged);
  }

  void _onFormatChanged() {
    if (!mounted) return;
    final hourIndex = timeFormatController.value
        ? _hour24
        : (_hour24 % 12 == 0 ? 11 : (_hour24 % 12) - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _hourController.jumpToItem(hourIndex);
      _periodController.jumpToItem(_hour24 >= 12 ? 1 : 0);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    timeFormatController.removeListener(_onFormatChanged);

    super.dispose();
  }

  Future<void> _openClockPicker() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
      switchToInputEntryModeIcon: const Icon(null),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(alwaysUse24HourFormat: timeFormatController.value),
        child: child!,
      ),
    );

    if (!mounted || selected == null) return;

    Navigator.pop(context, selected);
  }

  TimeOfDay get _selectedTime {
    return TimeOfDay(hour: _hour24, minute: _minute);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _openClockPicker,
                  icon: const Icon(Icons.schedule),
                  label: Text(context.t.clock),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ScheduleTimePickerColumn(
                  label: context.t.hour,
                  controller: _hourController,
                  itemCount: timeFormatController.value ? 24 : 12,
                  itemBuilder: (index) => timeFormatController.value
                      ? index.toString().padLeft(2, '0')
                      : '${index + 1}',
                  onChanged: (index) {
                    setState(() {
                      if (timeFormatController.value) {
                        _hour24 = index % 24;
                      } else {
                        final hour = (index % 12) + 1;
                        _hour24 = _isPm
                            ? (hour == 12 ? 12 : hour + 12)
                            : (hour == 12 ? 0 : hour);
                      }
                    });
                  },
                ),
                _ScheduleTimePickerColumn(
                  label: context.t.minute,
                  controller: _minuteController,
                  itemCount: 60,
                  itemBuilder: (index) => index.toString().padLeft(2, '0'),
                  onChanged: (index) {
                    setState(() {
                      _minute = index % 60;
                    });
                  },
                ),
                if (!timeFormatController.value)
                  _ScheduleTimePickerColumn(
                    label: context.t.period,
                    controller: _periodController,
                    itemCount: 2,
                    looping: false,
                    itemBuilder: (index) => index == 0 ? 'AM' : 'PM',
                    onChanged: (index) {
                      setState(() {
                        _isPm = index == 1;
                        final hour = _hour24 % 12;
                        _hour24 = _isPm
                            ? (hour == 0 ? 12 : hour + 12)
                            : (hour == 0 ? 0 : hour);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context, _selectedTime);
                },
                child: Text(
                  context.t.useTime(
                    formatScheduleTime(
                      _selectedTime,
                      use24HourTime: timeFormatController.value,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTimePickerColumn extends StatelessWidget {
  final String label;
  final FixedExtentScrollController controller;
  final int itemCount;
  final bool looping;
  final String Function(int index) itemBuilder;
  final ValueChanged<int> onChanged;

  const _ScheduleTimePickerColumn({
    required this.label,
    required this.controller,
    required this.itemCount,
    this.looping = true,
    required this.itemBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(label, style: GoogleFonts.manrope(color: colorScheme.onSurface)),
        const SizedBox(height: 8),
        SizedBox(
          width: 86,
          height: 150,
          child: CupertinoPicker(
            scrollController: controller,
            itemExtent: 40,
            looping: looping,
            onSelectedItemChanged: onChanged,
            selectionOverlay: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            children: List.generate(itemCount, (index) {
              return Center(
                child: Text(
                  itemBuilder(index),
                  style: GoogleFonts.manrope(color: colorScheme.onSurface),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

int _timeOfDayToMinutes(TimeOfDay time) {
  return time.hour * 60 + time.minute;
}

TimeOfDay _minutesToTimeOfDay(int minutesAfterMidnight) {
  return TimeOfDay(
    hour: minutesAfterMidnight ~/ 60,
    minute: minutesAfterMidnight % 60,
  );
}

String _formatWeekdays(List<int> weekdays, AppStrings t) {
  if (weekdays.length == 7) return t.everyDay;

  if (_sameWeekdays(weekdays, [1, 2, 3, 4, 5])) return t.scheduleWeekdays;

  if (_sameWeekdays(weekdays, [6, 7])) return t.scheduleWeekends;

  return weekdays.map((day) => t.weekdayShort[day - 1]).join(', ');
}

bool _sameWeekdays(List<int> weekdays, List<int> expected) {
  final sortedWeekdays = [...weekdays]..sort();

  if (sortedWeekdays.length != expected.length) return false;

  for (var index = 0; index < expected.length; index += 1) {
    if (sortedWeekdays[index] != expected[index]) return false;
  }

  return true;
}

class _TimerPresets extends StatelessWidget {
  final FixedExtentScrollController hoursController;
  final FixedExtentScrollController minutesController;
  final FixedExtentScrollController secondsController;

  const _TimerPresets({
    required this.hoursController,
    required this.minutesController,
    required this.secondsController,
  });

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 5,
      children: [
        _PresetButton(
          label: '5 min',
          onTap: () {
            timer.setDuration(hours: 0, minutes: 5, seconds: 0);
            _movePickers(hours: 0, minutes: 5, seconds: 0);
          },
        ),
        _PresetButton(
          label: '15 min',
          onTap: () {
            timer.setDuration(hours: 0, minutes: 15, seconds: 0);
            _movePickers(hours: 0, minutes: 15, seconds: 0);
          },
        ),
        _PresetButton(
          label: '30 min',
          onTap: () {
            timer.setDuration(hours: 0, minutes: 30, seconds: 0);
            _movePickers(hours: 0, minutes: 30, seconds: 0);
          },
        ),
        _PresetButton(label: '+', onTap: () {}),
      ],
    );
  }

  void _movePickers({
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    hoursController.animateToItem(
      hours,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    minutesController.animateToItem(
      minutes,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    secondsController.animateToItem(
      seconds,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(color: colorScheme.onSurface),
      ),
    );
  }
}

class _ActiveTimerCard extends StatelessWidget {
  const _ActiveTimerCard();

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;

    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) {
        final theme = Theme.of(context);

        final progress = timer.selectedDuration.inMilliseconds == 0
            ? 0.0
            : timer.remaining.inMilliseconds /
                  timer.selectedDuration.inMilliseconds;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  GradientCircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary,
                      ],
                    ),
                    backgroundColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.12,
                    ),
                    size: 200,
                  ),

                  Column(
                    children: [
                      Text(
                        timer.hasEnded
                            ? context.t.done
                            : formatRemaining(timer.remaining),
                        style: GoogleFonts.cormorantGaramond(fontSize: 30),
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(Icons.alarm),
                          Text(
                            formatEndTime(DateTime.now().add(timer.remaining)),
                            style: GoogleFonts.manrope(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),
              timer.hasEnded
                  ? Text(
                      context.t.timerEnded,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        // color: const Color(0xFF4E3B31),
                      ),
                    )
                  : _ActivePausedTimer(),
            ],
          ),
        );
      },
    );
  }
}

class _ActivePausedTimer extends StatelessWidget {
  const _ActivePausedTimer();

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;
    return timer.isPaused
        ? const _PausedTimerControls()
        : const _ActiveTimerControls();
  }
}

class _ActiveTimerControls extends StatelessWidget {
  const _ActiveTimerControls();

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: timer.cancelTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
          ),
          child: Text(
            context.t.cancel,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: timer.pauseTimer,
          child: Text(
            context.t.pause,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _PausedTimerControls extends StatelessWidget {
  const _PausedTimerControls();

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: timer.cancelTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
          ),
          child: Text(
            context.t.cancel,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: timer.resumeTimer,
          child: Text(
            context.t.resume,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}

// String formatDuration(Duration duration) {
//   String hours = duration.inHours.toString().padLeft(2, '0');
//   String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
//   String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
//   return "$hours:$minutes:$seconds";
// }

String formatRemaining(Duration duration) {
  final totalSeconds = (duration.inMilliseconds / 1000).ceil();

  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String formatEndTime(DateTime time) {
  String hours = time.hour.toString().padLeft(2, '0');
  String minutes = time.minute.toString().padLeft(2, '0');

  return '$hours:$minutes';
}
