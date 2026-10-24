// Rest for More - onboarding flow (single file)
//
// pubspec.yaml dependencies needed:
//   google_fonts: ^6.2.1
//   shared_preferences: ^2.3.2
//
// Use: OnboardingFlow(onFinished: (answers) => context.go('/'))
// Check on app start: await OnboardingFlow.isDone()

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';
import '../services/plan_service.dart';

// ---------- Theme (swap these if your team already has a theme file) ----------
const _bg = Color(0xFFFAF8F4);
const _brown = Color(0xFF7A5A40);
const _selectedFill = Color(0xFFE8DEC9);
const _card = Color(0xFFFFFEFB);
const _border = Color(0xFFECE5D9);
const _textDark = Color(0xFF4A3426);
const _textMuted = Color(0xFF9A8B7C);

// Tüm yazıları buradan büyütüp küçültebilirsin (1.0 = eski boyut)
const _fs = 1.25;

TextStyle _serif(double size, {Color color = _textDark}) =>
    GoogleFonts.cormorantGaramond(
        fontSize: size * _fs, color: color, fontWeight: FontWeight.w500, height: 1.1);
TextStyle _sans(double size,
        {Color color = _textDark, FontWeight w = FontWeight.w400}) =>
    GoogleFonts.montserrat(fontSize: size * _fs, color: color, fontWeight: w);

// ---------- Data ----------
class _Opt {
  final String label;
  final IconData icon;
  const _Opt(this.label, this.icon);
}

class _Step {
  final String key, label, title, subtitle;
  final List<_Opt> options;
  final bool multi;
  final int columns;
  const _Step(this.label, this.title, this.subtitle, this.options,
      {required this.key, this.multi = false, this.columns = 1});
}

List<_Step> _steps(AppStrings t) => [
      _Step(t.goalLabel, t.goalTitle, t.goalSubtitle, [
        _Opt(t.lessPhoneTime, Icons.phonelink_erase_outlined),
        _Opt(t.phoneFreeMoments, Icons.wb_sunny_outlined),
        _Opt(t.improveFocus, Icons.center_focus_strong_outlined),
        _Opt(t.healthierRoutine, Icons.spa_outlined),
      ], key: 'goal'),
      _Step(t.phoneHabitsLabel, t.habitsTitle, t.habitsSubtitle, [
        _Opt(t.morning, Icons.wb_sunny_outlined),
        _Opt(t.workStudy, Icons.work_outline),
        _Opt(t.evening, Icons.wb_twilight),
        _Opt(t.beforeSleep, Icons.bedtime_outlined),
      ], key: 'habits'),
      _Step(t.interestsLabel, t.interestsTitle, t.interestsSubtitle, [
        _Opt(t.reading, Icons.menu_book_outlined),
        _Opt(t.walking, Icons.directions_walk),
        _Opt(t.music, Icons.headphones_outlined),
        _Opt(t.cooking, Icons.soup_kitchen_outlined),
        _Opt(t.exercise, Icons.fitness_center),
        _Opt(t.creativeActivities, Icons.palette_outlined),
        _Opt(t.relaxing, Icons.weekend_outlined),
        _Opt(t.timeWithOthers, Icons.people_outline),
      ], key: 'interests', multi: true, columns: 2),
      _Step(t.preferredTimeLabel, t.preferredTimeTitle, t.preferredTimeSubtitle, [
        _Opt(t.morning, Icons.wb_twilight),
        _Opt(t.afternoon, Icons.wb_sunny_outlined),
        _Opt(t.evening, Icons.wb_twilight),
        _Opt(t.beforeBed, Icons.bed_outlined),
      ], key: 'time'),
      _Step(t.durationLabel, t.durationTitle, t.durationSubtitle, [
        _Opt(t.minutes(15), Icons.timer_outlined),
        _Opt(t.minutes(30), Icons.timer_outlined),
        _Opt(t.minutes(45), Icons.timer_outlined),
        _Opt(t.minutes(60), Icons.timer_outlined),
      ], key: 'duration', columns: 2),
    
      _Step('Plan length', 'How long should your plan be?',
          'Pick a length that feels doable, or choose your own number of days.', [
        _Opt('5 days', Icons.calendar_today_outlined),
        _Opt('7 days', Icons.calendar_today_outlined),
        _Opt('14 days', Icons.calendar_today_outlined),
        _Opt('Custom', Icons.tune),
      ], key: 'length', columns: 2),
    ];

// ---------- Flow ----------
class OnboardingFlow extends StatefulWidget {
  final void Function(Map<String, List<String>> answers) onFinished;
  const OnboardingFlow({super.key, required this.onFinished});

  static Future<bool> isDone() async =>
      (await SharedPreferences.getInstance()).getBool('onboarded') ?? false;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  // 0 = welcome, 1.._total = questions, _total + 1 = plan ready
  int _page = 0;
  final Map<String, Set<String>> _answers = {};
  int _customDays = 21;

  _Step get _step => _steps(context.t)[_page - 1];
  int get _total => _steps(context.t).length;
  Set<String> _sel(String key) => _answers[key] ?? {};

  void _toggle(_Step s, String label) {
    setState(() {
      final set = _answers.putIfAbsent(s.key, () => {});
      if (s.multi) {
        set.contains(label) ? set.remove(label) : set.add(label);
      } else {
        set
          ..clear()
          ..add(label);
      }
    });
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    if (_sel('length').contains('Custom')) {
      _answers['length'] = {'$_customDays days'};
    }
    final result = <String, List<String>>{};
    for (final e in _answers.entries) {
      result[e.key] = e.value.toList();
      await prefs.setStringList('onb_${e.key}', result[e.key]!);
    }
    await PlanService.reset();
    await prefs.setBool('onboarded', true);
    if (mounted) widget.onFinished(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                    key: ValueKey(_page),
                    child: _page == 0
                        ? _scroll(_welcome())
                        : _page == _total + 1
                            ? _scroll(_planReady())
                            : _question()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Welcome ve plan ekranı küçük ekranda taşmasın diye kaydırılabilir
  Widget _scroll(Widget child) => LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: IntrinsicHeight(child: child),
          ),
        ),
      );

  // "Custom" seçilince çıkan gün kaydırıcısı (3-30)
  Widget _customSlider() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(children: [
          Text('$_customDays days', style: _serif(26)),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _brown,
              thumbColor: _brown,
              inactiveTrackColor: _border,
              overlayColor: _brown.withAlpha(30),
            ),
            child: Slider(
              value: _customDays.toDouble(),
              min: 3,
              max: 30,
              divisions: 27,
              onChanged: (v) => setState(() => _customDays = v.round()),
            ),
          ),
        ]),
      );

  // ----- Welcome -----
  Widget _welcome() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),
          Text('RFM', style: _sans(18, color: _brown, w: FontWeight.w700)),
          const SizedBox(height: 20),
          Text(context.t.welcomeKicker,
              style: _sans(9, color: _brown, w: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(context.t.welcomeTitle, style: _serif(34)),
          const SizedBox(height: 14),
          Text(
              context.t.welcomeBody,
              style: _sans(12, color: _textMuted).copyWith(height: 1.5)),
          const SizedBox(height: 22),
          Text(context.t.welcomeSteps,
              style: _sans(10, color: _textMuted)),
          const Spacer(),
          Center(
              child: Text(context.t.preferencesLater,
                  style: _sans(10, color: _textMuted))),
          const SizedBox(height: 12),
          _button(context.t.getStarted, () => setState(() => _page = 1)),
        ],
      );

  // ----- Question step -----
  Widget _question() {
    final s = _step;
    final selected = _sel(s.key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          child: _page > 1
              ? GestureDetector(
                  onTap: () => setState(() => _page--),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.chevron_left, size: 16, color: _brown),
                    Text(context.t.back, style: _sans(11, color: _brown)),
                  ]),
                )
              : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.label.toUpperCase(),
                style: _sans(9, color: _brown, w: FontWeight.w600)),
            Text(context.t.stepOf(_page, _total),
                style: _sans(9, color: _brown, w: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(
            _total,
            (i) => Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < _total - 1 ? 6 : 0),
                decoration: BoxDecoration(
                  color: i < _page ? _brown : _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(s.title, style: _serif(32)),
        const SizedBox(height: 10),
        Text(s.subtitle, style: _sans(11, color: _textMuted)),
        const SizedBox(height: 22),
        Expanded(
          child: s.columns == 1
              ? ListView(
                  children: [
                    for (final o in s.options)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _tile(s, o, selected.contains(o.label)),
                      ),
                  ],
                )
              : GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: s.multi ? 1.9 : 1.35,
                  children: [
                    for (final o in s.options)
                      _tile(s, o, selected.contains(o.label)),
                  ],
                ),
        ),
        if (s.key == 'length' && selected.contains('Custom')) _customSlider(),
        _button(context.t.continueText, selected.isEmpty ? null : () => setState(() => _page++)),
      ],
    );
  }

  Widget _tile(_Step s, _Opt o, bool selected) {
    final iconBox = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: selected ? _brown : _selectedFill.withAlpha(120),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(o.icon, size: 20, color: selected ? Colors.white : _brown),
    );
    final check = selected
        ? const Icon(Icons.check_circle, size: 24, color: _brown)
        : const SizedBox(width: 24);
    final isDuration = s.key == 'duration';

    return GestureDetector(
      onTap: () => _toggle(s, o.label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? _selectedFill : _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _brown : _border, width: 1),
        ),
        child: isDuration
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconBox,
                  const SizedBox(height: 8),
                  Text(o.label, style: _sans(11)),
                ],
              )
            : Row(
                children: [
                  iconBox,
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(o.label,
                          style: _sans(11), maxLines: 2)),
                  check,
                ],
              ),
      ),
    );
  }

  // ----- Plan ready -----
  Widget _planReady() {
    String joined(String k) => _sel(k).join(', ');
    final len = _sel('length').contains('Custom')
        ? '$_customDays days'
        : joined('length');
    final rows = [
      (context.t.yourGoal, joined('goal'), Icons.wb_sunny_outlined),
      (context.t.bestTime, joined('time'), Icons.wb_twilight),
      (context.t.activities, joined('interests'), Icons.menu_book_outlined),
      (context.t.yourRhythm, joined('duration'), Icons.timer_outlined),
      ('PLAN LENGTH', len, Icons.calendar_today_outlined),
    ];
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
              color: _selectedFill, shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome, color: _brown, size: 30),
        ),
        const SizedBox(height: 22),
        Text(context.t.planKicker,
            style: _sans(9, color: _brown, w: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(context.t.planReady, style: _serif(30)),
        const SizedBox(height: 10),
        Text(
          context.t.planReadyBody,
          textAlign: TextAlign.center,
          style: _sans(11, color: _textMuted).copyWith(height: 1.5),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
              color: _selectedFill.withAlpha(150),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(rows[i].$3, size: 15, color: _brown),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rows[i].$1,
                                style: _sans(8,
                                    color: _textMuted, w: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(rows[i].$2, style: _sans(11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.check, size: 14, color: _textMuted),
                    ],
                  ),
                ),
                if (i < rows.length - 1)
                  Divider(height: 1, color: _border.withAlpha(200)),
              ],
            ],
          ),
        ),
        const Spacer(),
        _button(context.t.beginJourney, _finish),
      ],
    );
  }

  // ----- Shared button -----
  Widget _button(String text, VoidCallback? onTap) => SizedBox(
        width: double.infinity,
        height: 58,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: _brown,
            disabledBackgroundColor: _brown.withAlpha(90),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(text,
              style: _sans(12, color: Colors.white, w: FontWeight.w600)),
        ),
      );
}

// ---------- Standalone preview (remove when integrating) ----------
void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingFlow(onFinished: (a) => debugPrint('Answers: $a')),
    ));
