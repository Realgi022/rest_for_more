import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


const _bg = Color(0xFFFAF8F4);
const _brown = Color(0xFF7B563D);
const _selectedFill = Color(0xFFEBE6DA);
const _card = Color(0xFFFFFEFB);
const _border = Color(0xFFECE5D9);
const _textDark = Color(0xFF4E3B31);
const _textMuted = Color(0xFF9A8B7C);

TextStyle _serif(double size, {Color color = _textDark}) =>
    GoogleFonts.cormorantGaramond(
        fontSize: size, color: color, fontWeight: FontWeight.w500, height: 1.1);
TextStyle _sans(double size,
        {Color color = _textDark, FontWeight w = FontWeight.w400}) =>
    GoogleFonts.montserrat(fontSize: size, color: color, fontWeight: w);


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
  const _Step(this.key, this.label, this.title, this.subtitle, this.options,
      {this.multi = false, this.columns = 1});
}

const _steps = <_Step>[
  _Step('goal', 'Goal', 'What would you like to improve?',
      'Choose the goal that feels most meaningful right now.', [
    _Opt('Spend less time on my phone', Icons.phonelink_erase_outlined),
    _Opt('Create more phone-free moments', Icons.wb_sunny_outlined),
    _Opt('Improve my focus', Icons.center_focus_strong_outlined),
    _Opt('Build a healthier routine', Icons.spa_outlined),
  ]),
  _Step('habits', 'Phone habits', 'When is it hardest to put your phone away?',
      'This helps us suggest moments that fit naturally into your day.', [
    _Opt('Morning', Icons.wb_sunny_outlined),
    _Opt('Work/study', Icons.work_outline),
    _Opt('Evening', Icons.wb_twilight),
    _Opt('Before sleep', Icons.bedtime_outlined),
  ]),
  _Step('interests', 'Interests', 'What do you enjoy doing?',
      "Select as many as you like. We'll use them to personalize your journey.", [
    _Opt('Reading', Icons.menu_book_outlined),
    _Opt('Walking', Icons.directions_walk),
    _Opt('Music', Icons.headphones_outlined),
    _Opt('Cooking', Icons.soup_kitchen_outlined),
    _Opt('Exercise', Icons.fitness_center),
    _Opt('Creative activities', Icons.palette_outlined),
    _Opt('Relaxing', Icons.weekend_outlined),
    _Opt('Spending time with others', Icons.people_outline),
  ], multi: true, columns: 2),
  _Step('time', 'Preferred time', 'When would you like more phone free time?',
      "Pick the part of your day you'd most like to protect.", [
    _Opt('Morning', Icons.wb_twilight),
    _Opt('Afternoon', Icons.wb_sunny_outlined),
    _Opt('Evening', Icons.wb_twilight),
    _Opt('Before bed', Icons.bed_outlined),
  ]),
  _Step('duration', 'Duration', 'What feels achievable for you?',
      'Start with an amount of time that feels gentle and realistic.', [
    _Opt('15 minutes', Icons.timer_outlined),
    _Opt('30 minutes', Icons.timer_outlined),
    _Opt('45 minutes', Icons.timer_outlined),
    _Opt('60 minutes', Icons.timer_outlined),
  ], columns: 2),
];


class OnboardingFlow extends StatefulWidget {
  final void Function(Map<String, List<String>> answers) onFinished;
  const OnboardingFlow({super.key, required this.onFinished});

  static Future<bool> isDone() async =>
      (await SharedPreferences.getInstance()).getBool('onboarded') ?? false;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  // 0 = welcome, 1..5 = questions, 6 = plan ready
  int _page = 0;
  final Map<String, Set<String>> _answers = {};

  _Step get _step => _steps[_page - 1];
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
    final result = <String, List<String>>{};
    for (final e in _answers.entries) {
      result[e.key] = e.value.toList();
      await prefs.setStringList('onb_${e.key}', result[e.key]!);
    }
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
                        ? _welcome()
                        : _page == 6
                            ? _planReady()
                            : _question()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----- Welcome -----
  Widget _welcome() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),
          Image.asset(
            'assets/rfm_logo.png',
            width: 100,
          ),
          const SizedBox(height: 20),
          Text('WELCOME TO REST FOR MORE',
              style: _sans(9, color: _brown, w: FontWeight.w600)),
          const SizedBox(height: 12),
          Text("Let's create a plan that fits you.", style: _serif(34)),
          const SizedBox(height: 14),
          Text(
              "Answer a few quick questions about your routine and interests. We'll use your answers to create phone free activities that feel natural and achievable for you.",
              style: _sans(12, color: _textMuted).copyWith(height: 1.5)),
          const SizedBox(height: 22),
          Text('5 quick steps · Takes about 1 minute',
              style: _sans(10, color: _textMuted)),
          const Spacer(),
          Center(
              child: Text('You can adjust your preferences later.',
                  style: _sans(10, color: _textMuted))),
          const SizedBox(height: 12),
          _button('Get started', () => setState(() => _page = 1)),
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
                    Text('Back', style: _sans(11, color: _brown)),
                  ]),
                )
              : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.label.toUpperCase(),
                style: _sans(9, color: _brown, w: FontWeight.w600)),
            Text('STEP $_page OF 5',
                style: _sans(9, color: _brown, w: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(
            5,
            (i) => Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
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
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _tile(s, o, selected.contains(o.label)),
                      ),
                  ],
                )
              : GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: s.multi ? 2.4 : 1.7,
                  children: [
                    for (final o in s.options)
                      _tile(s, o, selected.contains(o.label)),
                  ],
                ),
        ),
        _button('Continue', selected.isEmpty ? null : () => setState(() => _page++)),
      ],
    );
  }

  Widget _tile(_Step s, _Opt o, bool selected) {
    final iconBox = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: selected ? _brown : _selectedFill.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(o.icon, size: 15, color: selected ? Colors.white : _brown),
    );
    final check = selected
        ? const Icon(Icons.check_circle, size: 18, color: _brown)
        : const SizedBox(width: 18);
    final isDuration = s.key == 'duration';

    return GestureDetector(
      onTap: () => _toggle(s, o.label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  const SizedBox(width: 10),
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
    final rows = [
      ('YOUR GOAL', joined('goal'), Icons.wb_sunny_outlined),
      ('BEST TIME', joined('time'), Icons.wb_twilight),
      ('ACTIVITIES', joined('interests'), Icons.menu_book_outlined),
      ('YOUR RHYTHM', joined('duration'), Icons.timer_outlined),
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
        Text('YOUR PERSONALIZED JOURNEY',
            style: _sans(9, color: _brown, w: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Your plan is ready', style: _serif(30)),
        const SizedBox(height: 10),
        Text(
          'Your daily activities are personalized from your answers, so each phone-free moment feels natural and achievable.',
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
        _button('Begin my journey  →', _finish),
      ],
    );
  }

  // ----- Shared button -----
  Widget _button(String text, VoidCallback? onTap) => SizedBox(
        width: double.infinity,
        height: 52,
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