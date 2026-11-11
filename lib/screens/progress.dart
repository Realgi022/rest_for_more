import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart' show CupertinoPicker;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';
import '../services/plan_service.dart';
import '../theme/app_card.dart';

const _icons = <String, IconData>{
  'Reading': Icons.menu_book_outlined,
  'Walking': Icons.directions_walk,
  'Music': Icons.headphones_outlined,
  'Cooking': Icons.soup_kitchen_outlined,
  'Exercise': Icons.fitness_center,
  'Creative activities': Icons.palette_outlined,
  'Relaxing': Icons.weekend_outlined,
  'Spending time with others': Icons.people_outline,
};

const _nouns = <String, String>{
  'Reading': 'reading',
  'Walking': 'walking',
  'Music': 'music',
  'Cooking': 'cooking',
  'Exercise': 'movement',
  'Creative activities': 'creating',
  'Relaxing': 'relaxing',
  'Spending time with others': 'time together',
};

const _short = <String, String>{
  'Reading': 'Read',
  'Walking': 'Walk',
  'Music': 'Listen',
  'Cooking': 'Cook',
  'Exercise': 'Move',
  'Creative activities': 'Create',
  'Relaxing': 'Relax',
  'Spending time with others': 'Connect',
};

const _boxName = 'RestNest';

/// Verandert telkens als het plan wijzigt, zodat Today en Progress elkaar bijwerken
final ValueNotifier<int> _planTick = ValueNotifier<int>(0);
void _planChanged() => _planTick.value++;

// Pauze blijft bewaard (ook als je het moment-scherm verlaat of de app sluit)
DateTime? _momentPausedAt;
DateTime _now() => _momentPausedAt ?? DateTime.now();

Future<MomentSession?> _activeMoment() async {
  final m = await PlanService.activeMoment();
  final p = await SharedPreferences.getInstance();
  if (m == null) {
    _momentPausedAt = null;
    await p.remove('moment_paused_at');
    return null;
  }
  final ms = p.getInt('moment_paused_at');
  _momentPausedAt =
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  return m;
}

Future<void> _setPaused(DateTime? at) async {
  _momentPausedAt = at;
  final p = await SharedPreferences.getInstance();
  if (at == null) {
    await p.remove('moment_paused_at');
  } else {
    await p.setInt('moment_paused_at', at.millisecondsSinceEpoch);
  }
}

Future<void> _clearMoment() async {
  await PlanService.clearMoment();
  await _setPaused(null);
}


/// Minuten die vandaag al gedaan zijn maar het doel nog niet bereiken.
Future<int> _partialMin(int day) async =>
    (await SharedPreferences.getInstance()).getInt('plan_partial_$day') ?? 0;

/// Verwerkt een afgeronde of gestopte sessie. De dag telt pas als voltooid
/// wanneer het doel (bv. 45 min) bereikt is; anders blijven de minuten bewaard
/// en kan je later doorgaan. Geeft true terug als de dag voltooid is.
Future<bool> _applySession(int day, int sessionMin, int goal) async {
  final p = await SharedPreferences.getInstance();
  final total = (p.getInt('plan_partial_$day') ?? 0) + sessionMin;
  if (total >= goal) {
    await PlanService.complete(day, minutes: goal);
    await p.remove('plan_partial_$day');
    return true;
  }
  await p.setInt('plan_partial_$day', total);
  return false;
}

String _mmss(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final m = d.inMinutes.toString().padLeft(2, '0');
  final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$sec';
}

IconData _iconFor(String category) => _icons[category] ?? Icons.spa_outlined;

String _momentTitle(PlanDay day, int minutes) =>
    '$minutes minutes of phone free ${_nouns[day.category] ?? 'time'}';

/// Figma paleti, açık ve koyu temaya göre.
class _Pal {
  final Color card, hero, primary, onPrimary, text, muted, line;
  const _Pal(this.card, this.hero, this.primary, this.onPrimary, this.text,
      this.muted, this.line);

  static _Pal of(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    if (dark) {
      // Koyu temada kartlar zeminle aynı renge düşmesin diye
      // sayfanın arka planına beyaz karıştırarak türetilir.
      final bg = theme.scaffoldBackgroundColor;
      Color lift(double a) =>
          Color.alphaBlend(Colors.white.withValues(alpha: a), bg);
      return _Pal(
        lift(0.10), // kart
        lift(0.17), // görsel alanı
        const Color(0xFFD8B79B), // vurgu
        const Color(0xFF2A1F19),
        const Color(0xFFF3EDE4),
        const Color(0xFFBDA999),
        lift(0.26), // çizgi
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

TextStyle _sans(BuildContext c, double size,
    {Color? color, FontWeight? w, double? h, double? ls}) {
  final base = Theme.of(c).textTheme.bodyMedium ?? const TextStyle();
  return base.copyWith(
      fontSize: size, color: color, fontWeight: w, height: h, letterSpacing: ls);
}

TextStyle _serif(BuildContext c, double size, {Color? color}) {
  final base = Theme.of(c).textTheme.headlineMedium ?? const TextStyle();
  return base.copyWith(fontSize: size, color: color, height: 1.15);
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  PlanData? _plan;
  bool _introSeen = true;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _planTick.addListener(_onTick);
    _load();
  }

  void _onTick() {
    if (mounted) _load();
  }

  MomentSession? _active;
  Timer? _ticker;
  int _partial = 0;

  Future<void> _load() async {
    var plan = await PlanService.load();
    final seen = await PlanService.introSeen();
    var active = await _activeMoment();

    if (active != null && !_now().isBefore(active.end)) {
      if (!plan.completed.contains(active.day)) {
        await _applySession(
            active.day, active.minutes, plan.minutesFor(active.day));
      }
      await _clearMoment();
      active = null;
      plan = await PlanService.load();
    }
    final partial = await _partialMin(plan.currentDay);

    if (!mounted) return;
    setState(() {
      _plan = plan;
      _introSeen = seen;
      _active = active;
      _partial = partial;
      if (_selected == null || _selected! > plan.total) {
        _selected = plan.currentDay;
      }
    });
    _syncTicker();
  }

  void _syncTicker() {
    _ticker?.cancel();
    _ticker = null;
    if (_active == null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final a = _active;
      if (a != null && !_now().isBefore(a.end)) {
        _load();
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _planTick.removeListener(_onTick);
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _openMoment(PlanData plan, PlanDay day) async {
    final running = _active != null && _active!.day == day.day ? _active : null;
    final goal = plan.minutesFor(day.day);
    final before = await _partialMin(day.day);
    final minutes = running?.minutes ?? (goal - before).clamp(1, goal).toInt();
    if (!mounted) return;
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => _MomentScreen(
          dayNumber: day.day,
          minutes: minutes,
          title: _momentTitle(day, goal),
          description: day.step.description,
          timeOfDay: plan.timeOfDay,
          resume: running,
        ),
      ),
    );
    if (result != null) {
      await _applySession(day.day, result, goal);
      await _clearMoment();
    }
    // Geri gidildiyse sayaç arka planda devam eder, burada yeniden okunur
    await _load();
    _planChanged();
  }

  void _openCalendar(PlanData plan, _Pal pal) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your ${plan.total}-day plan',
                  style: _serif(ctx, 26, color: pal.text)),
              const SizedBox(height: 4),
              Text('${plan.completed.length} of ${plan.total} days completed',
                  style: _sans(ctx, 12, color: pal.muted)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var d = 1; d <= plan.total; d++)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _selected = d);
                      },
                      child: Container(
                        width: 44,
                        height: 52,
                        decoration: BoxDecoration(
                          color: plan.completed.contains(d)
                              ? pal.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: d == plan.currentDay
                                  ? pal.primary
                                  : pal.line,
                              width: 1.2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$d',
                                style: _serif(ctx, 18,
                                    color: plan.completed.contains(d)
                                        ? pal.onPrimary
                                        : (d > plan.currentDay
                                            ? pal.muted
                                            : pal.text))),
                            SizedBox(
                              height: 12,
                              child: plan.completed.contains(d)
                                  ? Icon(Icons.check,
                                      size: 11, color: pal.onPrimary)
                                  : (d > plan.currentDay
                                      ? Icon(Icons.lock_outline,
                                          size: 10, color: pal.muted)
                                      : null),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: pal.muted),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await PlanService.debugSeedProgress();
                  setState(() => _selected = null);
                  await _load();
                  _planChanged();
                },
                child: const Text('Demo: show days 1–4 as done, start at day 5'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: pal.primary),
                onPressed: () async {
                  Navigator.pop(ctx);
                  // Plan opnieuw: vandaag is dag 1, alles gewist
                  await PlanService.reset();
                  final sp = await SharedPreferences.getInstance();
                  for (var i = 1; i <= 60; i++) {
                    await sp.remove('plan_partial_$i');
                  }
                  await PlanService.markIntroSeen();
                  setState(() => _selected = null);
                  await _load();
                  _planChanged();
                },
                child: const Text('Restart plan: today is day 1'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    if (plan == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final pal = _Pal.of(context);

    final Widget body = !_introSeen
        ? _Intro(
            plan: plan,
            pal: pal,
            onGo: () async {
              await PlanService.markIntroSeen();
              await _load();
            },
          )
        : _journey(plan, pal);

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.15)),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: body,
          ),
        ),
      ),
    );
  }

  Widget _journey(PlanData plan, _Pal pal) {
    final d = _selected ?? plan.currentDay;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Row(
          children: [
            // Test için: başlığa uzun bas, bir sonraki güne geç
            GestureDetector(
              onLongPress: () async {
                await PlanService.debugNextDay();
                await _load();
                _planChanged();
              },
              // Diğer sayfaların başlıklarıyla aynı boyutta olsun
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: Text('Progress',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => _openCalendar(plan, pal),
              icon: Icon(Icons.calendar_month, color: pal.primary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text('YOUR ${plan.total}-DAY PLAN',
            style: _sans(context, 11,
                color: pal.primary, w: FontWeight.w700, ls: 1)),
        const SizedBox(height: 14),
        _DayChips(
          plan: plan,
          pal: pal,
          selected: d,
          onSelect: (i) => setState(() => _selected = i),
        ),
        const SizedBox(height: 16),
        _dayCard(plan, d, pal),
        _history(plan, pal),
      ],
    );
  }

  Widget _history(PlanData plan, _Pal pal) {
    final done = plan.completed.toList()..sort();
    if (done.isEmpty) return const SizedBox.shrink();
    final t = context.t;
    final last = done.last;
    final lastDay = plan.days[last - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Text(t.completedMoments, style: _serif(context, 24, color: pal.text)),
        const SizedBox(height: 12),
        for (final d in done.reversed.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: pal.card, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(_iconFor(plan.days[d - 1].category),
                      color: pal.primary),
                  const SizedBox(width: 14),
                  Text('Day $d · ${_short[plan.days[d - 1].category] ?? plan.days[d - 1].category}',
                      style: _sans(context, 13, color: pal.text)),
                  const Spacer(),
                  Text('${plan.minutesDone[d] ?? plan.minutesFor(d)} min',
                      style: _sans(context, 11, color: pal.muted)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(t.stepCompleted, style: _serif(context, 24, color: pal.text)),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/progress/all-steps'),
              style: TextButton.styleFrom(foregroundColor: pal.primary),
              child: Text(t.seeAllSteps),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: pal.card, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_iconFor(lastDay.category), color: pal.primary),
                  const SizedBox(width: 14),
                  Text(t.todaysStep,
                      style: _sans(context, 13, color: pal.text)),
                  const Spacer(),
                  Text('Day $last',
                      style: _sans(context, 11, color: pal.muted)),
                ],
              ),
              const SizedBox(height: 8),
              Text(lastDay.step.title,
                  style: _sans(context, 13, color: pal.text, w: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(lastDay.step.description,
                  style: _sans(context, 12, color: pal.muted, h: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dayCard(PlanData plan, int d, _Pal pal) {
    final day = plan.days[d - 1];
    final minutes = plan.minutesFor(d);
    final done = plan.completed.contains(d);

    if (d > plan.currentDay) {
      return _FutureCard(day: day, minutes: minutes, pal: pal, daysAway: d - plan.currentDay);
    }
    if (d == plan.currentDay) {
      if (done) {
        return _CompleteCard(
          pal: pal,
          day: d,
          minutes: plan.minutesDone[d] ?? minutes,
          next: d < plan.total ? plan.days[d] : null,
          nextNumber: d + 1,
          onNext: () => setState(() => _selected = d + 1),
        );
      }
      return _TodayCard(
        pal: pal,
        day: day,
        minutes: minutes,
        timeOfDay: plan.timeOfDay,
        active: _active != null && _active!.day == d ? _active : null,
        partialMin: _partial,
        onStart: () => _openMoment(plan, day),
        onGoal: (m) async {
          if (_active != null) return; // sayaç çalışırken hedef değişmez
          await PlanService.setGoal(d, m);
          await _load();
          _planChanged();
        },
      );
    }
    return _PastCard(day: day, minutes: plan.minutesDone[d] ?? minutes, pal: pal, done: done);
  }
}

class _Intro extends StatelessWidget {
  final PlanData plan;
  final _Pal pal;
  final VoidCallback onGo;
  const _Intro({required this.plan, required this.pal, required this.onGo});

  @override
  Widget build(BuildContext context) {
    final chips = (plan.interests.isEmpty
            ? ['Reading', 'Walking', 'Relaxing']
            : plan.interests)
        .take(3)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        const SizedBox(height: 12),
        Text('Your ${plan.total} day plan',
            style: _serif(context, 34, color: pal.text)),
        const SizedBox(height: 12),
        Text(
          "Each day, you'll receive one small phone free step to make a little more room for what matters.",
          style: _sans(context, 13, color: pal.muted, h: 1.5),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: pal.card, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: pal.primary, shape: BoxShape.circle),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${plan.total}',
                            style: _serif(context, 22, color: pal.onPrimary)),
                        Text('DAYS',
                            style: _sans(context, 8,
                                color: pal.onPrimary, w: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('One step at a time',
                            style: _serif(context, 20, color: pal.text)),
                        const SizedBox(height: 4),
                        Text(
                            'Short, thoughtful moments designed to fit real days.',
                            style: _sans(context, 11, color: pal.muted, h: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                            color: pal.hero,
                            borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          children: [
                            Icon(_iconFor(chips[i]),
                                size: 22, color: pal.primary),
                            const SizedBox(height: 6),
                            Text(_short[chips[i]] ?? chips[i],
                                style: _sans(context, 11,
                                    color: pal.text, w: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    if (i < chips.length - 1) const SizedBox(width: 10),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Icon(Icons.favorite_border, size: 16, color: pal.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No scores or pressure. Simply begin your journey as you are.',
                style: _sans(context, 11, color: pal.muted, h: 1.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _PrimaryButton(pal: pal, label: "Let's go", icon: Icons.arrow_forward, onTap: onGo),
      ],
    );
  }
}

class _DayChips extends StatefulWidget {
  final PlanData plan;
  final _Pal pal;
  final int selected;
  final ValueChanged<int> onSelect;
  const _DayChips(
      {required this.plan,
      required this.pal,
      required this.selected,
      required this.onSelect});

  @override
  State<_DayChips> createState() => _DayChipsState();
}

class _DayChipsState extends State<_DayChips> {
  static const double _chipW = 58;
  static const double _gap = 8;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // Na de eerste opbouw naar de gekozen dag scrollen (zonder animatie)
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected(false));
  }

  @override
  void didUpdateWidget(covariant _DayChips old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected(true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _centerSelected(bool animate) {
    if (!mounted || !_controller.hasClients) return;
    final pos = _controller.position;
    final target = (widget.selected - 1) * (_chipW + _gap) -
        (pos.viewportDimension / 2 - _chipW / 2);
    final offset = target.clamp(0.0, pos.maxScrollExtent).toDouble();
    if (animate) {
      _controller.animateTo(offset,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _controller.jumpTo(offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final pal = widget.pal;
    final selected = widget.selected;
    final onSelect = widget.onSelect;
    return SizedBox(
      height: 74,
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            GestureBinding.instance.pointerSignalResolver
                .register(event, (_) {});
          }
        },
        child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: PointerDeviceKind.values.toSet(),
        ),
        child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: plan.total,
        separatorBuilder: (_, __) => const SizedBox(width: _gap),
        itemBuilder: (context, i) {
          final d = i + 1;
          final isSel = d == selected;
          final isToday = d == plan.currentDay;
          final done = plan.completed.contains(d);
          final locked = d > plan.currentDay;
          // Vandaag is altijd bruin gevuld. Een andere gekozen dag krijgt
          // alleen een dikkere rand.
          final filled = isToday;
          return GestureDetector(
            onTap: () => onSelect(d),
            child: Opacity(
              opacity: locked && !isSel ? 0.65 : 1,
              child: Container(
                width: _chipW,
                decoration: BoxDecoration(
                  color: filled ? pal.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isSel || isToday ? pal.primary : pal.line,
                      width: isSel && !isToday ? 2.4 : 1.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isToday ? 'TODAY' : 'DAY',
                        style: _sans(context, 8,
                            color: filled ? pal.onPrimary : pal.muted,
                            w: FontWeight.w700,
                            ls: 0.5)),
                    const SizedBox(height: 2),
                    Text('$d',
                        style: _serif(context, 22,
                            color: filled ? pal.onPrimary : pal.text)),
                    SizedBox(
                      height: 10,
                      child: done
                          ? Icon(Icons.check,
                              size: 10,
                              color: filled ? pal.onPrimary : pal.primary)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String category;
  final _Pal pal;
  final bool faded;
  final double height;
  const _Hero(
      {required this.category,
      required this.pal,
      this.faded = false,
      this.height = 150});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: pal.hero,
      alignment: Alignment.center,
      child: Opacity(
        opacity: faded ? 0.5 : 1,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: pal.card.withAlpha(200),
            shape: BoxShape.circle,
            border: Border.all(color: pal.line),
          ),
          child: Icon(_iconFor(category), size: 32, color: pal.primary),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final IconData? icon;
  final _Pal pal;
  const _Tag({required this.text, required this.pal, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: pal.hero, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: pal.muted),
            const SizedBox(width: 4),
          ],
          Text(text, style: _sans(context, 9, color: pal.muted, w: FontWeight.w700, ls: 0.5)),
        ],
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  final _Pal pal;
  final List<Widget> children;
  const _Shell({required this.pal, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: pal.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: pal.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final _Pal pal;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton(
      {required this.pal,
      required this.label,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: pal.primary,
          foregroundColor: pal.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: _sans(context, 13, color: pal.onPrimary, w: FontWeight.w600)),
            const SizedBox(width: 10),
            Icon(icon, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final _Pal pal;
  final PlanDay day;
  final int minutes;
  final String timeOfDay;
  final MomentSession? active;
  final int partialMin;
  final VoidCallback onStart;
  final ValueChanged<int> onGoal;
  const _TodayCard(
      {required this.pal,
      required this.day,
      required this.minutes,
      required this.timeOfDay,
      required this.onStart,
      required this.onGoal,
      this.partialMin = 0,
      this.active});

  Future<void> _pickCustom(BuildContext context) async {
    final m = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: pal.hero,
      builder: (ctx) => _GoalSheet(pal: pal, minutes: minutes),
    );
    if (m != null) onGoal(m);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Shell(
          pal: pal,
          children: [
            _Hero(category: day.category, pal: pal),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('DAY ${day.day} · TODAY',
                          style: _sans(context, 10,
                              color: pal.primary, w: FontWeight.w700, ls: 1)),
                      const Spacer(),
                      Icon(Icons.timer_outlined, size: 14, color: pal.muted),
                      const SizedBox(width: 4),
                      Text('$minutes min',
                          style: _sans(context, 11, color: pal.muted)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_momentTitle(day, minutes),
                      style: _serif(context, 26, color: pal.text)),
                  const SizedBox(height: 8),
                  Text(day.step.description,
                      style: _sans(context, 12, color: pal.muted, h: 1.5)),
                  const SizedBox(height: 18),
                  if (active != null) ...[
                    Row(
                      children: [
                        Icon(Icons.hourglass_bottom,
                            size: 16, color: pal.primary),
                        const SizedBox(width: 8),
                        Text(
                            'In progress · ${_mmss(active!.end.difference(_now()))} left',
                            style: _sans(context, 12,
                                color: pal.primary, w: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _PrimaryButton(
                        pal: pal,
                        label: 'Open moment',
                        icon: Icons.timer_outlined,
                        onTap: onStart),
                  ] else ...[
                    if (partialMin > 0) ...[
                      Row(
                        children: [
                          Icon(Icons.timelapse, size: 16, color: pal.primary),
                          const SizedBox(width: 8),
                          Text('$partialMin of $minutes min done so far',
                              style: _sans(context, 12,
                                  color: pal.primary, w: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    _PrimaryButton(
                        pal: pal,
                        label: partialMin > 0
                            ? "Continue today's session"
                            : "Start today's moment",
                        icon: Icons.play_arrow_rounded,
                        onTap: onStart),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (active == null) ...[
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: pal.card, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Adjust today's goal",
                  style: _sans(context, 13, color: pal.text, w: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('Choose what works for you today',
                  style: _sans(context, 11, color: pal.muted)),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final m in const [15, 30, 45]) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onGoal(m),
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: m == minutes ? pal.primary : pal.hero,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('$m min',
                              style: _sans(context, 12,
                                  color: m == minutes ? pal.onPrimary : pal.text,
                                  w: FontWeight.w600)),
                        ),
                      ),
                    ),
                    if (m != 45) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickCustom(context),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const [15, 30, 45].contains(minutes)
                        ? pal.hero
                        : pal.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.alarm,
                          size: 16,
                          color: const [15, 30, 45].contains(minutes)
                              ? pal.text
                              : pal.onPrimary),
                      const SizedBox(width: 8),
                      Text(
                          const [15, 30, 45].contains(minutes)
                              ? 'Set your own time'
                              : 'Your time: ${_fmtMin(minutes)} · change',
                          style: _sans(context, 12,
                              color: const [15, 30, 45].contains(minutes)
                                  ? pal.text
                                  : pal.onPrimary,
                              w: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ] else ...[
          const SizedBox(height: 12),
          Text(
              'Wrong time? Open the moment and cancel it. The minutes you have done are kept.',
              textAlign: TextAlign.center,
              style: _sans(context, 11, color: pal.muted, h: 1.4)),
        ],
      ],
    );
  }
}

String _fmtMin(int m) {
  if (m < 60) return '$m min';
  final h = m ~/ 60, r = m % 60;
  return r == 0 ? '$h h' : '$h h $r min';
}

/// Kendi süreni seç: alarm kurar gibi saat + dakika tekerlekleri.
/// En az 15 dk, en çok 3 saat; dakikalar 5'er 5'er.
class _GoalSheet extends StatefulWidget {
  final _Pal pal;
  final int minutes;
  const _GoalSheet({required this.pal, required this.minutes});

  static const int minMin = 15, maxMin = 180;

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  late int _h; // saat 0-3
  late int _m; // dakika sırası: 0 = 00 ... 11 = 55
  late final FixedExtentScrollController _hc;
  late final FixedExtentScrollController _mc;

  int get _total => _h * 60 + _m * 5;

  void _setFrom(int total) {
    final c = total.clamp(_GoalSheet.minMin, _GoalSheet.maxMin);
    _h = c ~/ 60;
    _m = (c % 60) ~/ 5;
  }

  @override
  void initState() {
    super.initState();
    _setFrom(widget.minutes);
    _hc = FixedExtentScrollController(initialItem: _h);
    _mc = FixedExtentScrollController(initialItem: _m);
  }

  @override
  void dispose() {
    _hc.dispose();
    _mc.dispose();
    super.dispose();
  }

  // Tekerlekler durunca sınır dışıysa en yakın geçerli süreye getir.
  void _settle() {
    final c = _total.clamp(_GoalSheet.minMin, _GoalSheet.maxMin);
    if (c != _total) {
      _setFrom(c);
      _hc.animateToItem(_h,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      _mc.animateToItem(_m,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
    setState(() {});
  }

  Widget _wheel(FixedExtentScrollController c, int count,
      String Function(int) text, ValueChanged<int> onChange) {
    final pal = widget.pal;
    return Expanded(
      child: CupertinoPicker(
        scrollController: c,
        itemExtent: 38,
        backgroundColor: Colors.transparent,
        selectionOverlay: Container(
          decoration: BoxDecoration(
            color: pal.primary.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: pal.line),
          ),
        ),
        onSelectedItemChanged: onChange,
        children: [
          for (var i = 0; i < count; i++)
            Center(
                child: Text(text(i),
                    style: _serif(context, 22, color: pal.text))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = widget.pal;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set your own time', style: _serif(context, 24, color: pal.text)),
            const SizedBox(height: 4),
            Text('Between 15 min and 3 h',
                style: _sans(context, 11, color: pal.muted)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (_) {
                  _settle();
                  return false;
                },
                child: Row(
                  children: [
                    _wheel(_hc, 4, (i) => '$i h', (i) => _h = i),
                    _wheel(
                        _mc,
                        12,
                        (i) => '${(i * 5).toString().padLeft(2, '0')} min',
                        (i) => _m = i),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(foregroundColor: pal.muted),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _PrimaryButton(
                    pal: pal,
                    label: 'Save ${_fmtMin(_total.clamp(_GoalSheet.minMin, _GoalSheet.maxMin))}',
                    icon: Icons.check,
                    onTap: () => Navigator.pop(
                        context,
                        _total.clamp(_GoalSheet.minMin, _GoalSheet.maxMin)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteCard extends StatelessWidget {
  final _Pal pal;
  final int day, minutes, nextNumber;
  final PlanDay? next;
  final VoidCallback onNext;
  const _CompleteCard(
      {required this.pal,
      required this.day,
      required this.minutes,
      required this.next,
      required this.nextNumber,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 150,
          height: 150,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: pal.card, shape: BoxShape.circle),
          child: Container(
            width: 96,
            height: 96,
            decoration:
                BoxDecoration(color: pal.primary, shape: BoxShape.circle),
            child: Icon(Icons.check, size: 40, color: pal.onPrimary),
          ),
        ),
        const SizedBox(height: 20),
        Text('A MOMENT MADE',
            style: _sans(context, 10, color: pal.primary, w: FontWeight.w700, ls: 1)),
        const SizedBox(height: 8),
        Text('Day $day complete', style: _serif(context, 34, color: pal.text)),
        const SizedBox(height: 8),
        Text('You spent $minutes ${minutes == 1 ? 'minute' : 'minutes'} phone-free today.',
            textAlign: TextAlign.center,
            style: _sans(context, 12, color: pal.muted)),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: pal.card, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Icon(Icons.nights_stay_outlined, size: 20, color: pal.primary),
              const SizedBox(height: 8),
              Text(
                next == null
                    ? "You've reached the end of your plan. Well done."
                    : 'Your next small step will be ready tomorrow.',
                textAlign: TextAlign.center,
                style: _serif(context, 20, color: pal.text),
              ),
              const SizedBox(height: 6),
              Text("For now, there's nothing more to do.",
                  textAlign: TextAlign.center,
                  style: _sans(context, 11, color: pal.muted)),
            ],
          ),
        ),
        if (next != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onNext,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: pal.card, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: pal.hero, borderRadius: BorderRadius.circular(10)),
                    child: Icon(_iconFor(next!.category),
                        size: 20, color: pal.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UP NEXT · DAY $nextNumber',
                            style: _sans(context, 9,
                                color: pal.muted, w: FontWeight.w700, ls: 0.5)),
                        const SizedBox(height: 2),
                        Text(next!.step.title,
                            style: _serif(context, 17, color: pal.text)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: pal.muted),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FutureCard extends StatelessWidget {
  final PlanDay day;
  final int minutes, daysAway;
  final _Pal pal;
  const _FutureCard(
      {required this.day,
      required this.minutes,
      required this.daysAway,
      required this.pal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Shell(
          pal: pal,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  Text('DAY ${day.day}',
                      style: _sans(context, 10,
                          color: pal.primary, w: FontWeight.w700, ls: 1)),
                  const Spacer(),
                  _Tag(
                      pal: pal,
                      icon: Icons.lock_outline,
                      text: 'AVAILABLE IN $daysAway ${daysAway == 1 ? 'DAY' : 'DAYS'}'),
                ],
              ),
            ),
            _Hero(category: day.category, pal: pal, faded: true),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.step.title,
                      style: _serif(context, 24, color: pal.text)),
                  const SizedBox(height: 6),
                  Text(day.step.description,
                      style: _sans(context, 12, color: pal.muted, h: 1.5)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: pal.card, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Icon(Icons.schedule, size: 18, color: pal.muted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'For now, stay with today. This step will open when it\'s time.',
                  style: _sans(context, 11, color: pal.muted, h: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PastCard extends StatelessWidget {
  final PlanDay day;
  final int minutes;
  final _Pal pal;
  final bool done;
  const _PastCard(
      {required this.day,
      required this.minutes,
      required this.pal,
      required this.done});

  @override
  Widget build(BuildContext context) {
    return _Shell(
      pal: pal,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Row(
            children: [
              Text('DAY ${day.day}',
                  style: _sans(context, 10,
                      color: pal.primary, w: FontWeight.w700, ls: 1)),
              const Spacer(),
              _Tag(
                pal: pal,
                icon: done ? Icons.check : null,
                text: done ? 'COMPLETED GENTLY' : 'NOT COMPLETED',
              ),
            ],
          ),
        ),
        _Hero(category: day.category, pal: pal, faded: !done),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_momentTitle(day, minutes),
                  style: _serif(context, 24, color: pal.text)),
              const SizedBox(height: 6),
              Text(
                done
                    ? day.step.description
                    : "That's okay. Every day is a fresh start.",
                style: _sans(context, 12, color: pal.muted, h: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MomentScreen extends StatefulWidget {
  final int dayNumber, minutes;
  final String title, description, timeOfDay;
  final MomentSession? resume;
  const _MomentScreen(
      {required this.dayNumber,
      required this.minutes,
      required this.title,
      required this.description,
      required this.timeOfDay,
      this.resume});

  @override
  State<_MomentScreen> createState() => _MomentScreenState();
}

class _MomentScreenState extends State<_MomentScreen> {
  MomentSession? _session;
  Timer? _timer;
  bool _finished = false;
  DateTime? get _pausedAt => _momentPausedAt;

  bool get _paused => _pausedAt != null;
  DateTime get _clock => _now();

  Duration get _total => Duration(minutes: widget.minutes);
  Duration get _left {
    final s = _session;
    if (s == null) return _total;
    final d = s.end.difference(_clock);
    return d.isNegative ? Duration.zero : d;
  }

  /// Bij hervatten schuiven we de starttijd op met de pauzeduur.
  Future<void> _shiftStart(Duration by) async {
    final s = _session;
    if (s == null) return;
    final moved = s.start.add(by);
    final p = await SharedPreferences.getInstance();
    await p.setInt('moment_start', moved.millisecondsSinceEpoch);
    _session = MomentSession(s.day, s.minutes, moved);
  }

  Future<void> _togglePause() async {
    if (_session == null) return;
    if (_paused) {
      final by = DateTime.now().difference(_pausedAt!);
      await _shiftStart(by);
      await _setPaused(null);
      if (!mounted) return;
      setState(() {});
    } else {
      await _setPaused(DateTime.now());
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _session = widget.resume;
    if (_session != null) _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_paused) return;
      if (_left == Duration.zero) {
        _complete(widget.minutes);
      } else {
        setState(() {});
      }
    });
  }

  Future<void> _begin() async {
    await PlanService.startMoment(widget.dayNumber, widget.minutes);
    final s = await _activeMoment();
    if (!mounted) return;
    setState(() => _session = s);
    _startTicker();
  }

  void _complete(int minutes) {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    Navigator.of(context).pop(minutes);
  }

  Future<void> _finishEarly() async {
    final s = _session;
    if (s == null) return;
    final elapsed = _clock.difference(s.start).inSeconds;
    final doneMin = (elapsed / 60).ceil().clamp(1, widget.minutes).toInt();
    if (doneMin < widget.minutes) {
      final stop = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Finish early?'),
          content: Text(
              'You have done $doneMin of ${widget.minutes} minutes. Today only counts as finished when you reach your goal, but you can continue later. Pause if you just need a break.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep going')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Stop for now')),
          ],
        ),
      );
      if (stop != true) return;
    }
    _complete(doneMin);
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this moment?'),
        content: const Text(
            'The minutes you have done so far will still be counted. You can continue later.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep going')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancel moment')),
        ],
      ),
    );
    if (ok != true) return;
    final st = _session;
    final doneMin = st == null
        ? 0
        : (_clock.difference(st.start).inSeconds ~/ 60)
            .clamp(0, widget.minutes)
            .toInt();
    if (doneMin > 0) {
      _complete(doneMin);
      return;
    }
    _timer?.cancel();
    await _clearMoment();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = _Pal.of(context);
    final running = _session != null;
    final progress =
        running ? 1 - _left.inMilliseconds / _total.inMilliseconds : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.15)),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Row(
                      children: [
                        Icon(Icons.chevron_left, color: pal.muted),
                        Text('Back', style: _sans(context, 12, color: pal.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text("DAY ${widget.dayNumber} TODAY'S ACTIVITY",
                          style: _sans(context, 10,
                              color: pal.primary, w: FontWeight.w700, ls: 1)),
                      const Spacer(),
                      _Tag(
                          pal: pal,
                          icon: Icons.wb_twilight,
                          text: widget.timeOfDay.toUpperCase()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                    decoration: BoxDecoration(
                        color: pal.card, borderRadius: BorderRadius.circular(28)),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 230,
                          height: 230,
                          child: CustomPaint(
                            painter: _RingPainter(
                                progress: progress.clamp(0.0, 1.0),
                                color: pal.primary,
                                track: pal.line),
                            child: Center(
                              child: Text(_mmss(_left),
                                  style: _serif(context, 44, color: pal.text)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(widget.title,
                            textAlign: TextAlign.center,
                            style: _serif(context, 26, color: pal.text)),
                        const SizedBox(height: 8),
                        Text(widget.description,
                            textAlign: TextAlign.center,
                            style: _sans(context, 12, color: pal.muted, h: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: pal.card, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 18, color: pal.muted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            running
                                ? (_paused
                                    ? 'Paused. Your time is waiting. Press Resume when you are ready.'
                                    : 'Leave your phone in $_boxName until the time is up. Your moment keeps running if you go back.')
                                : 'Leave your phone in $_boxName. Your minutes begin as soon as it is inside.',
                            style: _sans(context, 11, color: pal.muted, h: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (!running) ...[
                    _PrimaryButton(
                        pal: pal,
                        label: 'Start the moment',
                        icon: Icons.play_arrow_rounded,
                        onTap: _begin),
                    const SizedBox(height: 10),
                    Text(
                      'With the $_boxName box, this starts automatically when you place your phone inside.',
                      textAlign: TextAlign.center,
                      style: _sans(context, 10, color: pal.muted, h: 1.4),
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: _togglePause,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: pal.primary,
                        minimumSize: const Size.fromHeight(56),
                        side: BorderSide(color: pal.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: Icon(
                          _paused ? Icons.play_arrow_rounded : Icons.pause,
                          size: 20),
                      label: Text(_paused ? 'Resume' : 'Pause'),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton(
                        style: TextButton.styleFrom(foregroundColor: pal.muted),
                        onPressed: _cancel,
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color, track;
  const _RingPainter(
      {required this.progress, required this.color, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, 2 * math.pi * progress, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

// ───────────────────────── Today-pagina ─────────────────────────

const _tips = <String>[
  'Put your phone in another room while you do this.',
  'A little time away makes room for more.',
  'Keep something nice where you usually keep your phone.',
  'Start small. A slow moment counts as much as a long one.',
  'Turn on Do Not Disturb before you begin.',
  'Notice how you feel when you are done.',
];

/// Inhoud van de Today-pagina: dagbalk, activiteitskaart en een tip.
/// Gebruik in today.dart: const TodayActivity()
class TodayActivity extends StatefulWidget {
  const TodayActivity({super.key});

  @override
  State<TodayActivity> createState() => _TodayActivityState();
}

class _TodayActivityState extends State<TodayActivity> {
  PlanData? _plan;
  MomentSession? _active;
  Timer? _ticker;
  int _partial = 0;

  @override
  void initState() {
    super.initState();
    _planTick.addListener(_onTick);
    _load();
  }

  void _onTick() {
    if (mounted) _load();
  }

  @override
  void dispose() {
    _planTick.removeListener(_onTick);
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    var plan = await PlanService.load();
    var active = await _activeMoment();
    if (active != null && !_now().isBefore(active.end)) {
      if (!plan.completed.contains(active.day)) {
        await _applySession(
            active.day, active.minutes, plan.minutesFor(active.day));
      }
      await _clearMoment();
      active = null;
      plan = await PlanService.load();
    }
    final partial = await _partialMin(plan.currentDay);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _active = active;
      _partial = partial;
    });
    _ticker?.cancel();
    _ticker = null;
    if (active != null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final a = _active;
        if (a != null && !_now().isBefore(a.end)) {
          _load();
        } else {
          setState(() {});
        }
      });
    }
  }

  Future<void> _openMoment(PlanData plan, PlanDay day) async {
    final running = _active != null && _active!.day == day.day ? _active : null;
    final goal = plan.minutesFor(day.day);
    final before = await _partialMin(day.day);
    final minutes = running?.minutes ?? (goal - before).clamp(1, goal).toInt();
    if (!mounted) return;
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => _MomentScreen(
          dayNumber: day.day,
          minutes: minutes,
          title: _momentTitle(day, goal),
          description: day.step.description,
          timeOfDay: plan.timeOfDay,
          resume: running,
        ),
      ),
    );
    if (result != null) {
      await _applySession(day.day, result, goal);
      await _clearMoment();
    }
    await _load();
    _planChanged();
  }

  Future<void> _changeTime(PlanData plan, int day, int minutes, _Pal pal) async {
    final m = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: pal.hero,
      builder: (ctx) => _GoalSheet(pal: pal, minutes: minutes),
    );
    if (m != null) {
      await PlanService.setGoal(day, m);
      await _load();
      _planChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    if (plan == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final pal = _Pal.of(context);
    final d = plan.currentDay.clamp(1, plan.total);
    final day = plan.days[d - 1];
    final done = plan.completed.contains(d);
    // De titel blijft het doel van vandaag (bv. 45 min), ook na eerder stoppen
    final minutes = plan.minutesFor(d);
    final running = _active != null && _active!.day == d ? _active : null;
    final tip = _tips[d % _tips.length];

    // Phone-vrije tijd van vandaag: klaar = alles, bezig = verstreken tijd
    final totalSec = minutes * 60;
    int elapsedSec = 0;
    if (done) {
      elapsedSec = ((plan.minutesDone[d] ?? minutes) * 60).clamp(0, totalSec).toInt();
    } else if (running != null) {
      final left = running.end.difference(_now()).inSeconds;
      final session = (running.minutes * 60 - left).clamp(0, running.minutes * 60).toInt();
      elapsedSec = (_partial * 60 + session).clamp(0, totalSec).toInt();
    } else {
      elapsedSec = (_partial * 60).clamp(0, totalSec).toInt();
    }
    final fraction = totalSec == 0 ? 0.0 : elapsedSec / totalSec;
    final doneMin = elapsedSec ~/ 60;
    final leftMin = ((totalSec - elapsedSec) / 60).ceil();
    final freeText = done
        ? (doneMin < minutes
            ? 'You gave $doneMin of $minutes minutes. Every moment counts.'
            : 'You made time for yourself. Every moment counts.')
        : (running != null || _partial > 0
            ? "You're doing beautifully. Just $leftMin ${leftMin == 1 ? 'minute' : 'minutes'} to go."
            : 'A little time away makes room for more.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dagbalk
        Row(
          children: [
            Text('Day $d of ${plan.total}',
                style: _sans(context, 13, color: pal.text, w: FontWeight.w600)),
            const Spacer(),
            Text('YOUR ${plan.total}-DAY PLAN',
                style: _sans(context, 9, color: pal.muted, w: FontWeight.w600, ls: 1)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 1; i <= plan.total; i++) ...[
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: plan.completed.contains(i)
                        ? pal.primary
                        : (i == d ? pal.primary.withAlpha(110) : pal.line),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (i != plan.total) const SizedBox(width: 3),
            ],
          ],
        ),
        const SizedBox(height: 20),

        // Activiteitskaart
        _Shell(
          pal: pal,
          children: [
            Stack(
              children: [
                done
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        color: pal.hero,
                        alignment: Alignment.center,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: pal.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, size: 34, color: pal.onPrimary),
                        ),
                      )
                    : _Hero(category: day.category, pal: pal),
                if (done)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _Tag(text: 'COMPLETED', pal: pal),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("TODAY'S CHALLENGE",
                          style: _sans(context, 10,
                              color: pal.primary, w: FontWeight.w700, ls: 1)),
                      const Spacer(),
                      Icon(Icons.timer_outlined, size: 14, color: pal.muted),
                      const SizedBox(width: 4),
                      Text(_fmtMin(minutes),
                          style: _sans(context, 11, color: pal.muted)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_momentTitle(day, minutes),
                      style: _serif(context, 26, color: pal.text)),
                  const SizedBox(height: 8),
                  Text(
                      done
                          ? 'You made time for yourself. Well done.'
                          : day.step.description,
                      style: _sans(context, 12, color: pal.muted, h: 1.5)),
                  if (!done) ...[
                    const SizedBox(height: 18),
                    if (running != null) ...[
                      Row(
                        children: [
                          Icon(Icons.hourglass_bottom,
                              size: 16, color: pal.primary),
                          const SizedBox(width: 8),
                          Text(
                              'In progress · ${_mmss(running.end.difference(_now()))} left',
                              style: _sans(context, 12,
                                  color: pal.primary, w: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _PrimaryButton(
                          pal: pal,
                          label: 'Open moment',
                          icon: Icons.timer_outlined,
                          onTap: () => _openMoment(plan, day)),
                    ] else ...[
                      _PrimaryButton(
                          pal: pal,
                          label: _partial > 0 ? "Continue today's session" : 'Start activity',
                          icon: Icons.play_arrow_rounded,
                          onTap: () => _openMoment(plan, day)),
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(foregroundColor: pal.muted),
                          onPressed: () => _changeTime(plan, d, minutes, pal),
                          icon: const Icon(Icons.alarm, size: 16),
                          label: Text('Change time',
                              style: _sans(context, 12, color: pal.muted)),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),

        // Phone-free today
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: appCardDecoration(context, radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Phone-free today',
                      style: _sans(context, 13,
                          color: pal.text, w: FontWeight.w600)),
                  const Spacer(),
                  Text('$doneMin/$minutes min',
                      style: _sans(context, 12,
                          color: pal.text, w: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 8,
                  backgroundColor: pal.line,
                  valueColor: AlwaysStoppedAnimation<Color>(pal.primary),
                ),
              ),
              const SizedBox(height: 10),
              Text(freeText, style: _sans(context, 11, color: pal.muted)),
            ],
          ),
        ),

        // Tip: een enkele regel
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.wb_sunny_outlined, size: 16, color: pal.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(tip,
                  style: _sans(context, 12, color: pal.muted, h: 1.5)),
            ),
          ],
        ),
      ],
    );
  }
}
