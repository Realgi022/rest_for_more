import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_for_more/localization/app_language.dart';
import 'package:rest_for_more/models/mode_schedule.dart';
import 'package:rest_for_more/services/mode_schedule_service.dart';
import 'package:rest_for_more/services/focus_history_service.dart';
import 'package:rest_for_more/services/timer_service.dart';
import 'package:rest_for_more/services/time_format_controller.dart';

// Lettertypen komen uit het app-thema, zodat deze pagina er hetzelfde uitziet
// als de andere pagina's.
TextStyle _serif(BuildContext c, double? size, {Color? color}) {
  final base = Theme.of(c).textTheme.headlineMedium ?? const TextStyle();
  return base.copyWith(fontSize: size, color: color);
}

TextStyle _sans(BuildContext c, double? size,
    {Color? color, FontWeight? w, double? h, double? ls}) {
  final base = Theme.of(c).textTheme.bodyMedium ?? const TextStyle();
  return base.copyWith(
      fontSize: size, color: color, fontWeight: w, height: h, letterSpacing: ls);
}

/// Zelfde kleuren als de Today- en Progress-pagina.
class _Pal {
  final Color card, hero, primary, onPrimary, text, muted, line;
  const _Pal(this.card, this.hero, this.primary, this.onPrimary, this.text,
      this.muted, this.line);

  static _Pal of(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      final bg = theme.scaffoldBackgroundColor;
      Color lift(double a) =>
          Color.alphaBlend(Colors.white.withValues(alpha: a), bg);
      return _Pal(
        lift(0.10),
        lift(0.17),
        const Color(0xFFD8B79B),
        const Color(0xFF2A1F19),
        const Color(0xFFF3EDE4),
        const Color(0xFFBDA999),
        lift(0.26),
      );
    }
    return const _Pal(
      Color(0xFFEBE6DA),
      Color(0xFFF4F0E7),
      Color(0xFF7B563D),
      Colors.white,
      Color(0xFF4E3B31),
      Color(0xFF8E7B6C),
      Color(0xFFD9D0BF),
    );
  }
}

/// Today en Progress tonen hun tekst iets groter; hier ook, zodat het gelijk is.
Widget _scaled(BuildContext context, Widget child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.15)),
      child: child,
    );


class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  const _PillButton(
      {required this.label, required this.onTap, this.filled = true});

  @override
  Widget build(BuildContext context) {
    final pal = _Pal.of(context);
    final textStyle = _sans(context, 14,
        color: filled ? pal.onPrimary : pal.text, w: FontWeight.w600);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: filled
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: pal.primary,
                foregroundColor: pal.onPrimary,
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
              ),
              child: Text(label, style: textStyle),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: pal.text,
                minimumSize: const Size.fromHeight(52),
                side: BorderSide(color: pal.line),
                shape: const StadiumBorder(),
              ),
              child: Text(label, style: textStyle),
            ),
    );
  }
}

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
      listenable: Listenable.merge([timer, timeFormatController]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(toolbarHeight: 44),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: _scaled(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Header(),
                    const SizedBox(height: 18),
                    _TimerCard(),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    // Zelfde opbouw als de Today-pagina: titel zonder schaling, ondertitel
    // in bodyMedium met gedempte kleur.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Text(
            context.t.focus,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.t.focusMomentTimer,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
        ),
      ],
    );
  }
}

class _TimerCard extends StatelessWidget {
  _TimerCard();

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;

    return timer.timerStarted
        ? const _ActiveTimerCard()
        : const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InactiveTimerCard(),
              SizedBox(height: 36),
              _ModeScheduleSection(modeId: ModeId.focus),
              SizedBox(height: 36),
              _FocusHistorySection(),
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

  int get _h => timer.selectedHours;
  int get _m => timer.selectedMinutes;
  int get _s => timer.selectedSeconds;

  int get _total => _h * 3600 + _m * 60 + _s;

  void _set(int h, int m, int s) {
    timer.setDuration(hours: h, minutes: m, seconds: s);
  }

  void _start() {
    if (_total == 0) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Choose a time first.')),
      );
      return;
    }
    timer.startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) => _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final pal = _Pal.of(context);
    final t = context.t;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
          decoration: BoxDecoration(
            color: pal.hero,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TimeStepper(
                    value: _h,
                    max: 23,
                    label: t.hours.toLowerCase(),
                    onChanged: (v) => _set(v, _m, _s),
                  ),
                  const _Colon(),
                  _TimeStepper(
                    value: _m,
                    max: 59,
                    label: t.minutesLabel.toLowerCase(),
                    onChanged: (v) => _set(_h, v, _s),
                  ),
                  const _Colon(),
                  _TimeStepper(
                    value: _s,
                    max: 59,
                    label: t.seconds.toLowerCase(),
                    onChanged: (v) => _set(_h, _m, v),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _TimerPresets(
                currentSeconds: _total,
                onApply: (seconds) => _set(
                  seconds ~/ 3600,
                  (seconds % 3600) ~/ 60,
                  seconds % 60,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PillButton(label: t.start, onTap: _start),
        const SizedBox(height: 12),
        _PillButton(
          label: t.planFocus,
          filled: false,
          onTap: () => _openScheduleForm(context, ModeId.focus),
        ),
      ],
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) {
    final pal = _Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 52),
      child: Text(':', style: _serif(context, 34, color: pal.muted)),
    );
  }
}

/// Getal met pijltjes erboven en eronder. Tikken op een pijltje of
/// omhoog/omlaag slepen op het getal verandert de waarde.
class _TimeStepper extends StatefulWidget {
  final int value;
  final int max;
  final String label;
  final ValueChanged<int> onChanged;
  final String Function(int)? format;

  const _TimeStepper({
    required this.value,
    required this.max,
    required this.label,
    required this.onChanged,
    this.format,
  });

  @override
  State<_TimeStepper> createState() => _TimeStepperState();
}

class _TimeStepperState extends State<_TimeStepper> {
  static const double _stepPx = 22;
  double _drag = 0;

  int _wrap(int v) {
    final n = widget.max + 1;
    return ((v % n) + n) % n;
  }

  void _step(int by) => widget.onChanged(_wrap(widget.value + by));

  void _onDrag(DragUpdateDetails d) {
    _drag += d.delta.dy;
    var v = widget.value;
    var changed = false;
    while (_drag <= -_stepPx) {
      _drag += _stepPx;
      v = _wrap(v + 1);
      changed = true;
    }
    while (_drag >= _stepPx) {
      _drag -= _stepPx;
      v = _wrap(v - 1);
      changed = true;
    }
    if (changed) widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    final pal = _Pal.of(context);

    Widget chevron(IconData icon, int by) => InkResponse(
          onTap: () => _step(by),
          radius: 22,
          child: SizedBox(
            width: 56,
            height: 36,
            child: Icon(icon, size: 24, color: pal.muted),
          ),
        );

    return SizedBox(
      width: 92,
      child: Column(
        children: [
          chevron(Icons.keyboard_arrow_up, 1),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: _onDrag,
            onVerticalDragEnd: (_) => _drag = 0,
            child: SizedBox(
              height: 74,
              child: Center(
                child: Text(
                  widget.format?.call(widget.value) ??
                      widget.value.toString().padLeft(2, '0'),
                  style: _serif(context, 46, color: pal.text).copyWith(height: 1.4),
                ),
              ),
            ),
          ),
          Text(widget.label, style: _sans(context, 12, color: pal.muted)),
          chevron(Icons.keyboard_arrow_down, -1),
        ],
      ),
    );
  }
}

class _TimerPresets extends StatefulWidget {
  final int currentSeconds;
  final ValueChanged<int> onApply;

  const _TimerPresets({required this.currentSeconds, required this.onApply});

  @override
  State<_TimerPresets> createState() => _TimerPresetsState();
}

class _TimerPresetsState extends State<_TimerPresets> {
  static const _prefsKey = 'timer_custom_presets';
  static const _builtIn = [300, 600, 1200, 1800]; // 5, 10, 20 en 30 minuten

  List<int> _custom = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = (prefs.getStringList(_prefsKey) ?? const <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .where((s) => s > 0)
        .toList();
    if (!mounted) return;
    setState(() => _custom = saved);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _custom.map((s) => s.toString()).toList(),
    );
  }

  Future<void> _removeCustom(int seconds) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${_presetLabel(seconds)}?'),
        content: const Text('This preset will be removed from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (remove != true) return;

    setState(() => _custom = _custom.where((s) => s != seconds).toList());
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final pal = _Pal.of(context);
    final current = widget.currentSeconds;

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final seconds in _builtIn)
              _PresetChip(
                label: _presetLabel(seconds),
                selected: current == seconds,
                onTap: () => widget.onApply(seconds),
              ),
            for (final seconds in _custom)
              _PresetChip(
                label: _presetLabel(seconds),
                selected: current == seconds,
                onTap: () => widget.onApply(seconds),
                onLongPress: () => _removeCustom(seconds),
              ),
          ],
        ),
      ],
    );
  }
}

String _presetLabel(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  final parts = <String>[];
  if (hours > 0) parts.add('$hours h');
  if (minutes > 0) parts.add('$minutes min');
  if (seconds > 0) parts.add('$seconds sec');
  return parts.join(' ');
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final IconData? icon;
  final bool selected;
  final bool outlined;

  const _PresetChip({
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.icon,
    this.selected = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final pal = _Pal.of(context);
    final textColor = selected
        ? pal.onPrimary
        : (outlined ? pal.primary : pal.text);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? pal.primary
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected || outlined ? pal.primary : pal.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: _sans(context, 12, color: textColor, w: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}


Future<void> _openScheduleForm(
  BuildContext context,
  ModeId modeId, {
  ModeSchedule? existingSchedule,
}) async {
  final pal = _Pal.of(context);
  final result = await showModalBottomSheet<_ScheduleFormResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _scaled(
      context,
      _ScheduleFormSheet(schedule: existingSchedule, pal: pal),
    ),
  );

  if (result == null) return;

  if (existingSchedule != null) {
    await modeScheduleService.updateSchedule(
      existingSchedule.copyWith(
        name: result.name,
        weekdays: result.weekdays,
        startTimeMinutes: result.startTimeMinutes,
        endTimeMinutes: result.endTimeMinutes,
      ),
    );
    return;
  }

  await modeScheduleService.addSchedule(
    modeId: modeId,
    name: result.name,
    weekdays: result.weekdays,
    startTimeMinutes: result.startTimeMinutes,
    endTimeMinutes: result.endTimeMinutes,
  );
}

class _ModeScheduleSection extends StatelessWidget {
  final ModeId modeId;

  const _ModeScheduleSection({required this.modeId});

  @override
  Widget build(BuildContext context) {
    final pal = _Pal.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([modeScheduleService, timeFormatController]),
      builder: (context, _) {
        final schedules = modeScheduleService.schedulesFor(modeId);
        final schedule = schedules.isEmpty ? null : schedules.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.t.plannedFocus, style: _serif(context, 24, color: pal.text)),
            const SizedBox(height: 2),
            Text(
              context.t.chooseDaysAndTimeWindow,
              style: _sans(context, 13, color: pal.muted),
            ),
            const SizedBox(height: 14),
            if (schedule == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: pal.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.t.noSchedulesYet,
                  style: _sans(context, 13, color: pal.muted),
                ),
              )
            else
              _ScheduleTile(
                schedule: schedule,
                onTap: () => _openScheduleForm(
                  context,
                  modeId,
                  existingSchedule: schedule,
                ),
              ),
          ],
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
    final pal = _Pal.of(context);
    final use24 = timeFormatController.value;

    return Material(
      color: pal.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (schedule.name.isNotEmpty) ...[
                      Text(
                        schedule.name,
                        style: _serif(context, 22, color: pal.text),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      _formatWeekdays(schedule.weekdays, context.t),
                      style: _sans(context, 13, color: pal.muted, w: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatScheduleTime(_minutesToTimeOfDay(schedule.startTimeMinutes), use24HourTime: use24)} - '
                      '${formatScheduleTime(_minutesToTimeOfDay(schedule.endTimeMinutes), use24HourTime: use24)}',
                      style: _serif(context, 20, color: pal.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.t.tapToEdit,
                      style: _sans(context, 11, color: pal.muted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: schedule.enabled,
                activeColor: pal.onPrimary,
                activeTrackColor: pal.primary,
                onChanged: (enabled) {
                  modeScheduleService.setEnabled(schedule.id, enabled);
                },
              ),
              IconButton(
                onPressed: () => modeScheduleService.deleteSchedule(schedule.id),
                icon: Icon(Icons.delete_outline, color: pal.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleFormSheet extends StatefulWidget {
  final ModeSchedule? schedule;
  final _Pal pal;

  const _ScheduleFormSheet({this.schedule, required this.pal});

  @override
  State<_ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<_ScheduleFormSheet> {
  late Set<int> _weekdays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late final TextEditingController _nameController;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final schedule = widget.schedule;
    _nameController = TextEditingController(text: schedule?.name ?? '');

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
      title: context.t.startTime,
      initialTime: _startTime,
    );
    if (selected == null) return;
    setState(() => _startTime = selected);
  }

  Future<void> _pickEndTime() async {
    final selected = await _showScheduleTimePicker(
      context: context,
      title: context.t.endTime,
      initialTime: _endTime,
    );
    if (selected == null) return;
    setState(() => _endTime = selected);
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

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give your focus a name.')),
      );
      return;
    }

    if (_weekdays.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.chooseAtLeastOneDay)));
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
        name: name,
        weekdays: _weekdays.toList()..sort(),
        startTimeMinutes: startTimeMinutes,
        endTimeMinutes: endTimeMinutes,
      ),
    );
  }

  Widget _timeTile(String label, TimeOfDay time, VoidCallback onTap) {
    final pal = widget.pal;
    return Expanded(
      child: Material(
        color: pal.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: _sans(context, 12, color: pal.muted)),
                const SizedBox(height: 4),
                Text(
                  formatScheduleTime(
                    time,
                    use24HourTime: timeFormatController.value,
                  ),
                  style: _serif(context, 24, color: pal.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = widget.pal;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ListenableBuilder(
      listenable: timeFormatController,
      builder: (context, _) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: pal.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.schedule == null
                    ? context.t.planFocus
                    : context.t.editFocus,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 14),
              Text(
                'Name',
                style: _sans(context, 13, color: pal.muted, w: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 30,
                style: _sans(context, 15, color: pal.text),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'e.g. Morning focus',
                  hintStyle: _sans(context, 15, color: pal.muted),
                  filled: true,
                  fillColor: pal.card,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.t.days,
                style: _sans(context, 13, color: pal.muted, w: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final weekday = index + 1;
                  final selected = _weekdays.contains(weekday);

                  return GestureDetector(
                    onTap: () => _toggleWeekday(weekday),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? pal.primary : Colors.transparent,
                        border: Border.all(
                          color: selected ? pal.primary : pal.line,
                        ),
                      ),
                      child: Text(
                        context.t.weekdayShort[weekday - 1].characters.first
                            .toUpperCase(),
                        style: _sans(
                          context,
                          12,
                          color: selected ? pal.onPrimary : pal.text,
                          w: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _timeTile(context.t.from, _startTime, _pickStartTime),
                  const SizedBox(width: 12),
                  _timeTile(context.t.to, _endTime, _pickEndTime),
                ],
              ),
              const SizedBox(height: 18),
              _PillButton(
                label: widget.schedule == null
                    ? context.t.saveSchedule
                    : context.t.updateSchedule,
                onTap: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleFormResult {
  final String name;
  final List<int> weekdays;
  final int startTimeMinutes;
  final int endTimeMinutes;

  const _ScheduleFormResult({
    required this.name,
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
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => _scaled(
      sheetContext,
      _ScrollableTimePickerSheet(title: title, initialTime: initialTime),
    ),
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
  late int _hour; // 0-23 in 24-hour mode, 0-11 in 12-hour mode
  late int _minute;
  late bool _isPm;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTime;
    _minute = t.minute;
    _isPm = t.hour >= 12;
    _hour = timeFormatController.value ? t.hour : t.hour % 12;
  }

  TimeOfDay get _selectedTime {
    if (timeFormatController.value) {
      return TimeOfDay(hour: _hour, minute: _minute);
    }
    return TimeOfDay(hour: _hour + (_isPm ? 12 : 0), minute: _minute);
  }

  Widget _periodChip(String label, bool pm, _Pal pal) {
    final selected = _isPm == pm;
    return GestureDetector(
      onTap: () => setState(() => _isPm = pm),
      child: Container(
        width: 56,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? pal.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: selected ? pal.primary : pal.line),
        ),
        child: Text(
          label,
          style: _sans(context, 13,
              color: selected ? pal.onPrimary : pal.text,
              w: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = _Pal.of(context);
    final use24 = timeFormatController.value;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: pal.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.title,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
              decoration: BoxDecoration(
                color: pal.hero,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TimeStepper(
                    value: _hour,
                    max: use24 ? 23 : 11,
                    label: context.t.hour.toLowerCase(),
                    format: use24
                        ? null
                        : (v) => (v == 0 ? 12 : v).toString().padLeft(2, '0'),
                    onChanged: (v) => setState(() => _hour = v),
                  ),
                  const _Colon(),
                  _TimeStepper(
                    value: _minute,
                    max: 59,
                    label: context.t.minute.toLowerCase(),
                    onChanged: (v) => setState(() => _minute = v),
                  ),
                  if (!use24) ...[
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Column(
                        children: [
                          _periodChip('AM', false, pal),
                          const SizedBox(height: 8),
                          _periodChip('PM', true, pal),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _PillButton(
              label:
                  'Save ${formatScheduleTime(_selectedTime, use24HourTime: use24)}',
              onTap: () => Navigator.pop(context, _selectedTime),
            ),
          ],
        ),
      ),
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

class _ActiveTimerCard extends StatelessWidget {
  const _ActiveTimerCard();

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;

    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) {
        final pal = _Pal.of(context);
        final t = context.t;

        final totalMs = timer.selectedDuration.inMilliseconds;
        final progress =
            totalMs == 0 ? 0.0 : timer.remaining.inMilliseconds / totalMs;

        return SizedBox(
          width: double.infinity,
          child: Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              width: 290,
              height: 290,
              child: CustomPaint(
                painter: _TimerRingPainter(
                  progress: progress.clamp(0.0, 1.0),
                  color: pal.primary,
                  track: pal.line,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timer.hasEnded ? t.done : _clockText(timer.remaining),
                        style: _serif(context, 54, color: pal.text),
                      ),
                      if (!timer.hasEnded) ...[
                        const SizedBox(height: 6),
                        Text(
                          timer.isPaused
                              ? 'Paused'
                              : 'Ends at ${formatEndTime(DateTime.now().add(timer.remaining))}',
                          style: _sans(context, 13, color: pal.muted),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            if (timer.hasEnded)
              Text(
                t.timerEnded,
                textAlign: TextAlign.center,
                style: _serif(context, 22, color: pal.text),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      label: t.cancel,
                      filled: false,
                      onTap: timer.cancelTimer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PillButton(
                      label: timer.isPaused ? t.resume : t.pause,
                      onTap: timer.isPaused ? timer.resumeTimer : timer.pauseTimer,
                    ),
                  ),
                ],
              ),
          ],
          ),
        );
      },
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color, track;
  const _TimerRingPainter(
      {required this.progress, required this.color, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide / 2) - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = track,
    );
    canvas.drawArc(
      rect,
      -1.5707963267948966,
      6.283185307179586 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}

String _clockText(Duration duration) {
  final totalSeconds = (duration.inMilliseconds / 1000).ceil();
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
}

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

class _FocusHistorySection extends StatelessWidget {
  const _FocusHistorySection();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _when(DateTime d) {
    final now = DateTime.now();
    final time = formatEndTime(d);
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today, $time';
    if (diff == 1) return 'Yesterday, $time';
    return '${d.day} ${_months[d.month - 1]}, $time';
  }

  String _length(int seconds) {
    final m = seconds ~/ 60;
    final h = m ~/ 60;
    if (h > 0) return '$h h ${m % 60} min';
    if (m > 0) return '$m min';
    return '$seconds sec';
  }

  @override
  Widget build(BuildContext context) {
    final pal = _Pal.of(context);

    return ListenableBuilder(
      listenable: focusHistoryService,
      builder: (context, _) {
        final all = focusHistoryService.sessions;
        final items = all.take(5).toList();

        final now = DateTime.now();
        final todaySeconds = all
            .where((s) =>
                s.endedAt.year == now.year &&
                s.endedAt.month == now.month &&
                s.endedAt.day == now.day)
            .fold<int>(0, (sum, s) => sum + s.seconds);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Focus History',
                style: _serif(context, 24, color: pal.text)),
            const SizedBox(height: 2),
            Text(
              all.isEmpty
                  ? 'Your finished sessions will show up here.'
                  : 'Focused today: ${_length(todaySeconds)}',
              style: _sans(context, 13, color: pal.muted),
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: pal.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('No focus sessions yet.',
                    style: _sans(context, 13, color: pal.muted)),
              )
            else
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: pal.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        Divider(height: 1, indent: 18, endIndent: 18, color: pal.line),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_length(items[i].seconds),
                                      style: _serif(context, 22, color: pal.text)),
                                  const SizedBox(height: 2),
                                  Text(_when(items[i].endedAt),
                                      style: _sans(context, 12, color: pal.muted)),
                                ],
                              ),
                            ),
                            Icon(
                              items[i].completed
                                  ? Icons.check
                                  : Icons.timelapse,
                              size: 18,
                              color: items[i].completed ? pal.primary : pal.muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              items[i].completed ? 'Completed' : 'Stopped early',
                              style: _sans(context, 12,
                                  color: items[i].completed ? pal.primary : pal.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
