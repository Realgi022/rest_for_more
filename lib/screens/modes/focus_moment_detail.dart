import 'package:circle_time_progress/circle_time_progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rest_for_more/models/mode_schedule.dart';
import 'package:rest_for_more/services/mode_schedule_service.dart';
import 'package:rest_for_more/services/timer_service.dart';

class FocusMomentScreen extends StatefulWidget {
  const FocusMomentScreen({super.key});

  @override
  State<FocusMomentScreen> createState() => _FocusMomentScreenState();
}

class _FocusMomentScreenState extends State<FocusMomentScreen> {
  final timer = FocusTimerService.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const SizedBox(height: 32),
                  _TimerCard(),
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
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Focus",
          style: GoogleFonts.cormorantGaramond(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text("Focus moment timer", style: GoogleFonts.manrope(fontSize: 20)),
      ],
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard();

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;

    return timer.timerStarted
        ? const _ActiveTimerCard()
        : Column(
            children: [
              const _InactiveTimerCard(),
              const SizedBox(height: 24),
              _ModeScheduleSection(modeId: ModeId.focus),
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
        color: colorScheme.surfaceContainerHighest,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(
              'Start',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.normal,
                fontSize: 30,
              ),
            ),
          ),
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
          label: 'Hours',
          maxValue: 23,
          controller: hoursController,
          onChanged: timer.setHours,
        ),
        _TimePickerColumn(
          label: 'Minutes',
          maxValue: 59,
          controller: minutesController,
          onChanged: timer.setMinutes,
        ),
        _TimePickerColumn(
          label: 'Seconds',
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
          startTimeMinutes: schedule.startTimeMinutes,
          endTimeMinutes: schedule.endTimeMinutes,
        ),
      );
      return;
    }

    await modeScheduleService.addSchedule(
      modeId: modeId,
      weekdays: schedule.weekdays,
      startTimeMinutes: schedule.startTimeMinutes,
      endTimeMinutes: schedule.endTimeMinutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: modeScheduleService,
      builder: (context, _) {
        final schedules = modeScheduleService.schedulesFor(modeId);
        final schedule = schedules.isEmpty ? null : schedules.first;

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
                          'Planned ${modeId.label}',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Choose days and a time window.',
                          style: GoogleFonts.manrope(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (schedule == null)
                    IconButton.filled(
                      onPressed: () => _openScheduleForm(context),
                      icon: const Icon(Icons.add),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (schedule == null)
                Text(
                  'No schedules yet.',
                  style: GoogleFonts.manrope(color: colorScheme.onSurface),
                )
              else
                _ScheduleTile(
                  schedule: schedule,
                  onTap: () =>
                      _openScheduleForm(context, existingSchedule: schedule),
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
                      _formatWeekdays(schedule.weekdays),
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatTimeMinutes(schedule.startTimeMinutes)} - '
                      '${_formatTimeMinutes(schedule.endTimeMinutes)}',
                      style: GoogleFonts.manrope(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to edit',
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
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final schedule = widget.schedule;

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

  Future<void> _pickStartTime() async {
    final selected = await _showScheduleTimePicker(
      context: context,
      title: 'Start time',
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
      title: 'End time',
      initialTime: _endTime,
    );

    if (selected == null) return;

    setState(() {
      _endTime = selected;
    });
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_weekdays.contains(weekday)) {
        _weekdays.remove(weekday);
      } else {
        _weekdays.add(weekday);
      }
    });
  }

  void _save() {
    final startTimeMinutes = _timeOfDayToMinutes(_startTime);
    final endTimeMinutes = _timeOfDayToMinutes(_endTime);

    if (_weekdays.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Choose at least one day.')));
      return;
    }

    if (startTimeMinutes == endTimeMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose different start and end times.')),
      );
      return;
    }

    Navigator.pop(
      context,
      _ScheduleFormResult(
        weekdays: _weekdays.toList()..sort(),
        startTimeMinutes: startTimeMinutes,
        endTimeMinutes: endTimeMinutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.schedule == null
                  ? 'Plan ${widget.modeId.label}'
                  : 'Edit ${widget.modeId.label}',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Days',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final selected = _weekdays.contains(weekday);

                return ChoiceChip(
                  label: Text(_shortWeekdayName(weekday)),
                  selected: selected,
                  onSelected: (_) => _toggleWeekday(weekday),
                );
              }),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.play_arrow_outlined),
              title: const Text('From'),
              subtitle: Text(_startTime.format(context)),
              onTap: _pickStartTime,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.stop_outlined),
              title: const Text('To'),
              subtitle: Text(_endTime.format(context)),
              onTap: _pickEndTime,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(
                  widget.schedule == null ? 'Save schedule' : 'Update schedule',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleFormResult {
  final List<int> weekdays;
  final int startTimeMinutes;
  final int endTimeMinutes;

  const _ScheduleFormResult({
    required this.weekdays,
    required this.startTimeMinutes,
    required this.endTimeMinutes,
  });
}

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
  late int _hour;
  late int _minute;
  late bool _isPm;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late final FixedExtentScrollController _periodController;

  @override
  void initState() {
    super.initState();

    final hourOfPeriod = widget.initialTime.hour % 12;

    _hour = hourOfPeriod == 0 ? 12 : hourOfPeriod;
    _minute = widget.initialTime.minute;
    _isPm = widget.initialTime.hour >= 12;

    _hourController = FixedExtentScrollController(
      initialItem: _loopingInitialItem(itemCount: 12, selectedIndex: _hour - 1),
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _loopingInitialItem(itemCount: 60, selectedIndex: _minute),
    );
    _periodController = FixedExtentScrollController(initialItem: _isPm ? 1 : 0);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();

    super.dispose();
  }

  Future<void> _openClockPicker() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
      switchToInputEntryModeIcon: const Icon(null),
    );

    if (!mounted || selected == null) return;

    Navigator.pop(context, selected);
  }

  TimeOfDay get _selectedTime {
    final hour24 = _isPm
        ? (_hour == 12 ? 12 : _hour + 12)
        : (_hour == 12 ? 0 : _hour);

    return TimeOfDay(hour: hour24, minute: _minute);
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
                  label: const Text('Clock'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ScheduleTimePickerColumn(
                  label: 'Hour',
                  controller: _hourController,
                  itemCount: 12,
                  itemBuilder: (index) => '${index + 1}',
                  onChanged: (index) {
                    setState(() {
                      _hour = (index % 12) + 1;
                    });
                  },
                ),
                _ScheduleTimePickerColumn(
                  label: 'Minute',
                  controller: _minuteController,
                  itemCount: 60,
                  itemBuilder: (index) => index.toString().padLeft(2, '0'),
                  onChanged: (index) {
                    setState(() {
                      _minute = index % 60;
                    });
                  },
                ),
                _ScheduleTimePickerColumn(
                  label: 'Period',
                  controller: _periodController,
                  itemCount: 2,
                  looping: false,
                  itemBuilder: (index) => index == 0 ? 'AM' : 'PM',
                  onChanged: (index) {
                    setState(() {
                      _isPm = index == 1;
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
                child: Text('Use ${_selectedTime.format(context)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTimePickerColumn extends StatelessWidget {
  static const _loopingItemCount = 10000;

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
            onSelectedItemChanged: onChanged,
            selectionOverlay: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            children: List.generate(looping ? _loopingItemCount : itemCount, (
              index,
            ) {
              return Center(
                child: Text(
                  itemBuilder(looping ? index % itemCount : index),
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

int _loopingInitialItem({required int itemCount, required int selectedIndex}) {
  const middle = _ScheduleTimePickerColumn._loopingItemCount ~/ 2;

  return middle - (middle % itemCount) + selectedIndex;
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

String _formatWeekdays(List<int> weekdays) {
  if (weekdays.length == 7) return 'Every day';

  if (_sameWeekdays(weekdays, [1, 2, 3, 4, 5])) return 'Weekdays';

  if (_sameWeekdays(weekdays, [6, 7])) return 'Weekends';

  return weekdays.map(_shortWeekdayName).join(', ');
}

bool _sameWeekdays(List<int> weekdays, List<int> expected) {
  final sortedWeekdays = [...weekdays]..sort();

  if (sortedWeekdays.length != expected.length) return false;

  for (var index = 0; index < expected.length; index += 1) {
    if (sortedWeekdays[index] != expected[index]) return false;
  }

  return true;
}

String _shortWeekdayName(int weekday) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  return names[weekday - 1];
}

String _formatTimeMinutes(int minutesAfterMidnight) {
  final hour24 = minutesAfterMidnight ~/ 60;
  final minuteValue = minutesAfterMidnight % 60;
  final hourOfPeriod = hour24 % 12;
  final hour = hourOfPeriod == 0 ? 12 : hourOfPeriod;
  final minute = minuteValue.toString().padLeft(2, '0');
  final period = hour24 < 12 ? 'AM' : 'PM';

  return '$hour:$minute $period';
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

    // return ElevatedButton(
    //   onPressed: onTap,
    //   style: ElevatedButton.styleFrom(
    //     backgroundColor: const Color(0xFFFAF8F4),
    //     shape: CircleBorder(),
    //     padding: EdgeInsets.all(20),
    //   ),
    //   child: Text(
    //     label,
    //     textAlign: TextAlign.center,
    //     style: GoogleFonts.manrope(color: const Color(0xFF4E3B31)),
    //   ),
    // );
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
        final progress = timer.selectedDuration.inMilliseconds == 0
            ? 0.0
            : timer.remaining.inMilliseconds /
                  timer.selectedDuration.inMilliseconds;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFEBE6DA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  GradientCircularProgressIndicator(
                    value: progress,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B563D), Color(0xFF7B563D)],
                    ),
                    backgroundColor: Colors.grey.shade300,
                    size: 200,
                  ),

                  Text(
                    formatDuration(timer.remaining),
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 30,
                      color: const Color(0xFF4E3B31),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              _ActivePausedTimer(),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: timer.finishTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFAF8F4),
          ),
          child: Text(
            'Cancel',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: const Color(0xFF4E3B31),
              fontWeight: FontWeight.normal,
              fontSize: 30,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: timer.pauseTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E3B31),
          ),
          child: Text(
            'Pause',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: const Color(0xFFFAF8F4),
              fontWeight: FontWeight.normal,
              fontSize: 30,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: timer.finishTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFAF8F4),
          ),
          child: Text(
            'Cancel',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: const Color(0xFF4E3B31),
              fontWeight: FontWeight.normal,
              fontSize: 30,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: timer.resumeTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E3B31),
          ),
          child: Text(
            'Resume',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: const Color(0xFFFAF8F4),
              fontWeight: FontWeight.normal,
              fontSize: 30,
            ),
          ),
        ),
      ],
    );
  }
}

String formatDuration(Duration duration) {
  String hours = duration.inHours.toString().padLeft(2, '0');
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return "$hours:$minutes:$seconds";
}
