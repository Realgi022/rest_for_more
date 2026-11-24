import 'package:flutter/material.dart';

class TutorialBlock extends StatefulWidget {
  const TutorialBlock({super.key});

  @override
  State<TutorialBlock> createState() => _TutorialBlockState();
}

class _TutorialBlockState extends State<TutorialBlock> {
  final _controller = PageController(keepPage: false);
  int _index = 0;

  static const _steps = [
    (en: 'On the Blocked apps page, tap Open accessibility settings.', nl: 'Tik bij Geblokkeerde apps op Toegankelijkheidsinstellingen openen.'),
    (en: 'Under Accessibility, tap Installed apps.', nl: 'Tik onder Toegankelijkheid op Geïnstalleerde apps.'),
    (en: 'Select Rest For More app blocker.', nl: 'Kies Rest For More app blocker.'),
    (en: 'Turn on the top switch for the app blocker.', nl: 'Zet de bovenste schakelaar voor de appblokkeerder aan.'),
    (en: 'Read the Android permission prompt. If you agree, tap Allow.', nl: 'Lees welke toegang Android vraagt. Tik op Toestaan als je akkoord gaat.'),
    (en: 'Check that the switch is on, then tap the back arrow.', nl: 'Controleer of de schakelaar aan staat en tik op de pijl terug.'),
    (en: 'In Installed apps, check that Rest For More app blocker says On. Tap back.', nl: 'Controleer bij Geïnstalleerde apps of Rest For More app blocker aan staat. Tik op terug.'),
    (en: 'Tap back again to return to Rest For More.', nl: 'Tik nogmaals op terug om naar Rest For More te gaan.'),
    (en: 'On the Blocked apps page, swipe down to refresh the app list.', nl: 'Veeg op de pagina Geblokkeerde apps omlaag om de lijst te vernieuwen.'),
  ];

  void _goTo(int page) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dutch = Localizations.localeOf(context).languageCode == 'nl';
    final step = _steps[_index];
    final count = _steps.length;
    final last = _index == count - 1;
    final progress = dutch
        ? 'Stap ${_index + 1} van $count'
        : 'Step ${_index + 1} of $count';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dutch ? 'Apps blokkeren instellen' : 'Set up app blocking',
            style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: (MediaQuery.sizeOf(context).height * 0.48).clamp(220.0, 460.0).toDouble(),
            child: PageView.builder(
              controller: _controller,
              itemCount: count,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) => Image.asset(
                'assets/tutorial/app_blocker_samsung/step_${index + 1}.png',
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text('$progress\n${dutch ? step.nl : step.en}', style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(height: 8),
          OverflowBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _index == 0 ? null : () => _goTo(_index - 1),
                child: Text(dutch ? 'Vorige' : 'Previous'),
              ),
              TextButton(
                onPressed: () => _goTo(last ? 0 : _index + 1),
                child: Text(last
                    ? (dutch ? 'Opnieuw bekijken' : 'View again')
                    : (dutch ? 'Volgende' : 'Next')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
