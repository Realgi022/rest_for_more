import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en', '🇬🇧 English'),
  dutch('nl', '🇳🇱 Nederlands');

  final String code;
  final String label;

  const AppLanguage(this.code, this.label);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

class AppLanguageController extends ValueNotifier<AppLanguage> {
  AppLanguageController() : super(AppLanguage.english);

  static const _prefsKey = 'app_language';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    value = AppLanguage.fromCode(prefs.getString(_prefsKey));
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (value == language) return;

    value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  }
}

final appLanguageController = AppLanguageController();

class AppLanguageScope extends InheritedNotifier<AppLanguageController> {
  const AppLanguageScope({
    super.key,
    required AppLanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppLanguage languageOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLanguageScope>();
    return scope?.notifier?.value ?? appLanguageController.value;
  }
}

extension AppLocalizations on BuildContext {
  AppStrings get t => AppStrings(AppLanguageScope.languageOf(this));
}

class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  bool get _nl => language == AppLanguage.dutch;

  String get today => _nl ? 'Vandaag' : 'Today';
  String get modes => _nl ? 'Modi' : 'Modes';
  String get progress => _nl ? 'Voortgang' : 'Progress';
  String get settings => _nl ? 'Instellingen' : 'Settings';
  String get noTasksToday => _nl ? 'Geen taken voor vandaag!' : 'No tasks for today!';

  String get blockedApps => _nl ? 'Geblokkeerde apps' : 'Blocked apps';
  String get blockedAppsDescription => _nl
      ? 'Kies apps om te blokkeren op dit Android-apparaat.'
      : 'Choose apps to block on this Android device.';
  String get nightMode => _nl ? 'Nachtmodus' : 'Night Mode';
  String get nightModeDescription => _nl
      ? 'Gebruik donkere kleuren voor rust laat op de avond.'
      : 'Use darker colors for late-night rest.';
  String get languageTitle => _nl ? 'Taal' : 'Language';
  String get languageDescription => _nl
      ? 'Kies de taal voor de app.'
      : 'Choose the language for the app.';

  String get focus => _nl ? 'Focus' : 'Focus';
  String get focusDescription => _nl
      ? 'Blokkeer afleiding en blijf gefocust.'
      : 'Block distractions and stay focused.';
  String get reading => _nl ? 'Lezen' : 'Reading';
  String get readingDescription => _nl
      ? 'Creëer een rustige omgeving om te lezen.'
      : 'Create a quiet environment for reading.';
  String get evening => _nl ? 'Avond' : 'Evening';
  String get eveningDescription => _nl
      ? 'Verminder afleiding voordat je gaat slapen.'
      : 'Reduce distractions before going to sleep.';
  String get morning => _nl ? 'Ochtend' : 'Morning';
  String get morningDescription => _nl
      ? 'Begin je dag zonder onnodige afleiding.'
      : 'Start your day without unnecessary distractions.';

  String get thisWeeksMoments => _nl ? 'Momenten van deze week' : "This week's moments";
  List<String> get weekdayShort => _nl
      ? const ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo']
      : const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  String get completedMoments => _nl ? 'Voltooide momenten' : 'Completed moments';
  String get morningMoment => _nl ? 'Ochtend' : 'Morning';
  String get stepCompleted => _nl ? 'Stap voltooid' : 'Step completed';
  String get seeAllSteps => _nl ? 'Bekijk alle stappen' : 'See all steps';
  String get todaysStep => _nl ? 'Stap van vandaag' : "Today's step";
  String get day8 => _nl ? 'Dag 8' : 'Day 8';
  String get waterStepDone => _nl
      ? 'Je hebt vandaag 8 glazen water gedronken, goed gedaan!'
      : 'You drank 8 glasses of water today, great job!';

  String appsBlocked(int count) => _nl ? '$count apps geblokkeerd' : '$count apps blocked';
  String get couldNotLoadApps => _nl ? 'Kon geïnstalleerde apps niet laden.' : 'Could not load installed apps.';
  String get androidOnly => _nl ? 'Alleen Android' : 'Android only';
  String get androidOnlyMessage => _nl
      ? 'Apps blokkeren is alleen beschikbaar op Android-apparaten.'
      : 'App blocking is only available on Android devices.';
  String get somethingWentWrong => _nl ? 'Er is iets misgegaan' : 'Something went wrong';
  String get noAppsFound => _nl ? 'Geen apps gevonden' : 'No apps found';
  String get refreshAppsMessage => _nl
      ? 'Trek omlaag om de lijst met geïnstalleerde apps te vernieuwen.'
      : 'Pull down to refresh the installed apps list.';
  String get blockingEnabled => _nl ? 'Blokkeren is ingeschakeld' : 'Blocking is enabled';
  String get enableAppBlocking => _nl ? 'Apps blokkeren inschakelen' : 'Enable app blocking';
  String get blockingEnabledMessage => _nl
      ? 'Geselecteerde apps worden geblokkeerd wanneer ze worden geopend.'
      : 'Selected apps will be blocked when opened.';
  String get enableAppBlockingMessage => _nl
      ? 'Schakel de toegankelijkheidsservice van Rest For More in zodat Android geblokkeerde apps kan detecteren.'
      : 'Turn on the Rest For More accessibility service so Android can detect blocked apps.';
  String get refreshStatus => _nl ? 'Status vernieuwen' : 'Refresh status';
  String get openAccessibilitySettings => _nl ? 'Toegankelijkheidsinstellingen openen' : 'Open accessibility settings';

  String get welcomeKicker => _nl ? 'WELKOM BIJ REST FOR MORE' : 'WELCOME TO REST FOR MORE';
  String get welcomeTitle => _nl ? 'Laten we een plan maken dat bij je past.' : "Let's create a plan that fits you.";
  String get welcomeBody => _nl
      ? 'Beantwoord een paar korte vragen over je routine en interesses. We gebruiken je antwoorden om telefoonvrije activiteiten te maken die natuurlijk en haalbaar voelen.'
      : "Answer a few quick questions about your routine and interests. We'll use your answers to create phone free activities that feel natural and achievable for you.";
  String get welcomeSteps => _nl ? '5 korte stappen · Duurt ongeveer 1 minuut' : '5 quick steps · Takes about 1 minute';
  String get preferencesLater => _nl ? 'Je kunt je voorkeuren later aanpassen.' : 'You can adjust your preferences later.';
  String get getStarted => _nl ? 'Aan de slag' : 'Get started';
  String get back => _nl ? 'Terug' : 'Back';
  String stepOf(int step, int total) => _nl ? 'STAP $step VAN $total' : 'STEP $step OF $total';
  String get continueText => _nl ? 'Doorgaan' : 'Continue';
  String get planKicker => _nl ? 'JOUW PERSOONLIJKE REIS' : 'YOUR PERSONALIZED JOURNEY';
  String get planReady => _nl ? 'Je plan is klaar' : 'Your plan is ready';
  String get planReadyBody => _nl
      ? 'Je dagelijkse activiteiten zijn afgestemd op je antwoorden, zodat elk telefoonvrij moment natuurlijk en haalbaar voelt.'
      : 'Your daily activities are personalized from your answers, so each phone-free moment feels natural and achievable.';
  String get beginJourney => _nl ? 'Begin mijn reis  →' : 'Begin my journey  →';
  String get yourGoal => _nl ? 'JOUW DOEL' : 'YOUR GOAL';
  String get bestTime => _nl ? 'BESTE TIJD' : 'BEST TIME';
  String get activities => _nl ? 'ACTIVITEITEN' : 'ACTIVITIES';
  String get yourRhythm => _nl ? 'JOUW RITME' : 'YOUR RHYTHM';

  String get goalLabel => _nl ? 'Doel' : 'Goal';
  String get goalTitle => _nl ? 'Wat wil je verbeteren?' : 'What would you like to improve?';
  String get goalSubtitle => _nl ? 'Kies het doel dat nu het meest betekenisvol voelt.' : 'Choose the goal that feels most meaningful right now.';
  String get lessPhoneTime => _nl ? 'Minder tijd op mijn telefoon' : 'Spend less time on my phone';
  String get phoneFreeMoments => _nl ? 'Meer telefoonvrije momenten creëren' : 'Create more phone-free moments';
  String get improveFocus => _nl ? 'Mijn focus verbeteren' : 'Improve my focus';
  String get healthierRoutine => _nl ? 'Een gezondere routine opbouwen' : 'Build a healthier routine';
  String get phoneHabitsLabel => _nl ? 'Telefoongewoonten' : 'Phone habits';
  String get habitsTitle => _nl ? 'Wanneer is het het moeilijkst om je telefoon weg te leggen?' : 'When is it hardest to put your phone away?';
  String get habitsSubtitle => _nl ? 'Dit helpt ons momenten voor te stellen die natuurlijk in je dag passen.' : 'This helps us suggest moments that fit naturally into your day.';
  String get workStudy => _nl ? 'Werk/studie' : 'Work/study';
  String get beforeSleep => _nl ? 'Voor het slapen' : 'Before sleep';
  String get interestsLabel => _nl ? 'Interesses' : 'Interests';
  String get interestsTitle => _nl ? 'Wat doe je graag?' : 'What do you enjoy doing?';
  String get interestsSubtitle => _nl ? 'Selecteer zoveel als je wilt. We gebruiken ze om je reis persoonlijk te maken.' : "Select as many as you like. We'll use them to personalize your journey.";
  String get walking => _nl ? 'Wandelen' : 'Walking';
  String get music => _nl ? 'Muziek' : 'Music';
  String get cooking => _nl ? 'Koken' : 'Cooking';
  String get exercise => _nl ? 'Bewegen' : 'Exercise';
  String get creativeActivities => _nl ? 'Creatieve activiteiten' : 'Creative activities';
  String get relaxing => _nl ? 'Ontspannen' : 'Relaxing';
  String get timeWithOthers => _nl ? 'Tijd doorbrengen met anderen' : 'Spending time with others';
  String get preferredTimeLabel => _nl ? 'Voorkeurstijd' : 'Preferred time';
  String get preferredTimeTitle => _nl ? 'Wanneer wil je meer telefoonvrije tijd?' : 'When would you like more phone free time?';
  String get preferredTimeSubtitle => _nl ? 'Kies het deel van je dag dat je het liefst wilt beschermen.' : "Pick the part of your day you'd most like to protect.";
  String get afternoon => _nl ? 'Middag' : 'Afternoon';
  String get beforeBed => _nl ? 'Voor bed' : 'Before bed';
  String get durationLabel => _nl ? 'Duur' : 'Duration';
  String get durationTitle => _nl ? 'Wat voelt haalbaar voor jou?' : 'What feels achievable for you?';
  String get durationSubtitle => _nl ? 'Begin met een hoeveelheid tijd die zacht en realistisch voelt.' : 'Start with an amount of time that feels gentle and realistic.';
  String minutes(int count) => _nl ? '$count minuten' : '$count minutes';

  String get focusMomentTimer => _nl ? 'Focusmoment-timer' : 'Focus moment timer';
  String get start => _nl ? 'Start' : 'Start';
  String get hours => _nl ? 'Uren' : 'Hours';
  String get minutesLabel => _nl ? 'Minuten' : 'Minutes';
  String get seconds => _nl ? 'Seconden' : 'Seconds';
  String get done => _nl ? 'Klaar' : 'Done';
  String get timerEnded => _nl ? 'De timer is afgelopen' : 'The timer has ended';
  String get cancel => _nl ? 'Annuleren' : 'Cancel';
  String get pause => _nl ? 'Pauzeren' : 'Pause';
  String get resume => _nl ? 'Hervatten' : 'Resume';
  String get stop => _nl ? 'Stoppen' : 'Stop';
  String get activeTimer => _nl ? 'Actieve timer' : 'Active timer';
  String get activeTimerDescription => _nl
      ? 'Toont de timer die momenteel loopt'
      : 'Shows the currently running timer';
  String get focusTimer => _nl ? 'Focustimer' : 'Focus timer';
  String timerDuration(String duration) => _nl ? 'Timer $duration' : 'Timer $duration';
  String get timerPaused => _nl ? 'Timer gepauzeerd' : 'Timer paused';
}
