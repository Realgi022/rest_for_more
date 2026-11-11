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
  String get modes => _nl ? 'Modes' : 'Modes';
  String get progress => _nl ? 'Voortgang' : 'Progress';
  String get settings => _nl ? 'Instellingen' : 'Settings';
  String get noTasksToday => _nl ? 'Geen taken voor vandaag!' : 'No tasks for today!';

  String get blockedApps => _nl ? 'Geblokkeerde apps' : 'Blocked apps';
  String get blockedAppsDescription => _nl
      ? 'Kies apps om te blokkeren op dit apparaat.'
      : 'Choose apps to block on this device.';
  String get nightMode => _nl ? 'Nachtstand' : 'Night Mode';
  String get nightModeDescription => _nl
      ? 'Gebruik donkere kleuren voor rust laat op de avond.'
      : 'Use darker colors for late night rest.';
  String get languageTitle => _nl ? 'Taal' : 'Language';
  String get timeFormatTitle => _nl ? 'Tijd format' : 'Time format';
  String get timeFormatDescription => _nl
      ? 'Kies de tijdnotatie voor geplande focus.'
      : 'Choose the time format for planned focus.';
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
    List<String> get months => _nl
      ? const ['Januari', 'Februari', 'Maart', 'April', 'Mei', 'Juni', 'Juli', 'Augustus', 'september', 'Oktober', 'November', 'December',]
      : const ['January','February','March','April','May','June','July','August','September','October','November','December',];
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
      ? 'Apps blokkeren is alleen beschikbaar op Android apparaten.'
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
      ? 'Beantwoord een paar korte vragen over je routine en interesses. We gebruiken je antwoorden om telefoonvrije momenten te maken die natuurlijk en haalbaar voelen.'
      : "Answer a few quick questions about your routine and interests. We'll use your answers to create phone free moments that feel natural and achievable for you.";
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
      : 'Your daily activities are personalized from your answers, so each phone free moment feels natural and achievable.';
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

  String get focusMomentTimer => _nl ? 'Focusmoment timer' : 'Focus moment timer';
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

  // Focus scheduling translations.
  String get plannedFocus => _nl ? 'Geplande focus' : 'Planned Focus';
  String get chooseDaysAndTimeWindow => _nl
      ? 'Kies dagen en een tijdsperiode.'
      : 'Choose days and a time window.';
  String get addSchedule => _nl ? 'Planning toevoegen' : 'Add schedule';
  String get noSchedulesYet => _nl ? 'Nog geen planningen.' : 'No schedules yet.';
  String get tapToEdit => _nl ? 'Tik om te bewerken' : 'Tap to edit';
  String get startTime => _nl ? 'Starttijd' : 'Start time';
  String get endTime => _nl ? 'Eindtijd' : 'End time';
  String get chooseAtLeastOneDay => _nl
      ? 'Kies minimaal één dag.'
      : 'Choose at least one day.';
  String get chooseDifferentStartEndTimes => _nl
      ? 'Kies verschillende start- en eindtijden.'
      : 'Choose different start and end times.';
  String get planFocus => _nl ? 'Focus plannen' : 'Plan Focus';
  String get editFocus => _nl ? 'Focusplanning bewerken' : 'Edit Focus';
  String get days => _nl ? 'Dagen' : 'Days';
  String get from => _nl ? 'Van' : 'From';
  String get to => _nl ? 'Tot' : 'To';
  String get saveSchedule => _nl ? 'Planning opslaan' : 'Save schedule';
  String get updateSchedule => _nl ? 'Planning bijwerken' : 'Update schedule';
  String get clock => _nl ? 'Klok' : 'Clock';
  String get hour => _nl ? 'Uur' : 'Hour';
  String get minute => _nl ? 'Minuut' : 'Minute';
  String get period => _nl ? 'Dagdeel' : 'Period';
  String useTime(String time) => _nl ? 'Gebruik $time' : 'Use $time';
  String get everyDay => _nl ? 'Elke dag' : 'Every day';
  String get scheduleWeekdays => _nl ? 'Doordeweeks' : 'Weekdays';
  String get scheduleWeekends => _nl ? 'Weekenden' : 'Weekends';

  // All Steps translations from the previous screen update.
  String get completedStepsTitle =>
      _nl ? 'Voltooide stappen' : 'Completed steps';
  String stepNumber(int number) => _nl ? 'Stap $number' : 'Step $number';
  String get prepareForRestfulNight => _nl
      ? 'Bereid je voor op een goede nachtrust.'
      : 'Prepare for a restful night.';
  String get walkOutsideFor15Minutes => _nl
      ? 'Ga 15 minuten buiten wandelen.'
      : 'Walk outside for 15 minutes.';
  String get goTo => _nl ? 'Ga naar ' : 'Go to ';
  String get completeFirstStepOfMonth => _nl
      ? ' en voltooi je eerste stap van de maand.'
      : ' and complete your first step of the month.';
  String get trackCompletedStepsHere => _nl
      ? 'Bekijk hier je voltooide stappen.'
      : 'Track your completed steps here.';


  // Progress page and daily activity localization.
  String yourDayPlanTitle(int total) =>
      _nl ? 'Jouw $total-daagse plan' : 'Your $total-day plan';
  String yourDayPlanUpper(int total) =>
      _nl ? 'JOUW $total-DAAGSE PLAN' : 'YOUR $total-DAY PLAN';
  String daysCompleted(int done, int total) =>
      _nl ? '$done van de $total dagen voltooid' : '$done of $total days completed';
  String get demoProgress => _nl
      ? 'Demo: toon dag 1–4 als voltooid, begin bij dag 5'
      : 'Demo: show days 1–4 as done, start at day 5';
  String dayNumber(int day) => _nl ? 'Dag $day' : 'Day $day';
  String dayOfPlan(int day, int total) =>
      _nl ? 'Dag $day van $total' : 'Day $day of $total';
  String dayUpperNumber(int day) => _nl ? 'DAG $day' : 'DAY $day';
  String dayTodayUpper(int day) =>
      _nl ? 'DAG $day · VANDAAG' : 'DAY $day · TODAY';
  String get dayUpper => _nl ? 'DAG' : 'DAY';
  String get todayUpper => _nl ? 'VANDAAG' : 'TODAY';
  String dayActivity(int day, String category) =>
      '${dayNumber(day)} · ${categoryShort(category)}';

  String categoryShort(String category) {
    switch (category) {
      case 'Reading': return _nl ? 'Lees' : 'Read';
      case 'Walking': return _nl ? 'Wandel' : 'Walk';
      case 'Music': return _nl ? 'Luister' : 'Listen';
      case 'Cooking': return _nl ? 'Kook' : 'Cook';
      case 'Exercise': return _nl ? 'Beweeg' : 'Move';
      case 'Creative activities': return _nl ? 'Creëer' : 'Create';
      case 'Relaxing': return _nl ? 'Ontspan' : 'Relax';
      case 'Spending time with others': return _nl ? 'Samen' : 'Connect';
      default: return category;
    }
  }

  String phoneFreeMomentTitle(int duration, String category) {
    if (_nl) {
      switch (category) {
        case 'Reading': return '$duration minuten telefoonvrij lezen';
        case 'Walking': return '$duration minuten telefoonvrij wandelen';
        case 'Music': return '$duration minuten telefoonvrij muziek luisteren';
        case 'Cooking': return '$duration minuten telefoonvrij koken';
        case 'Exercise': return '$duration minuten telefoonvrij bewegen';
        case 'Creative activities': return '$duration minuten telefoonvrij creatief bezig zijn';
        case 'Relaxing': return '$duration minuten telefoonvrij ontspannen';
        case 'Spending time with others': return '$duration minuten telefoonvrij samenzijn';
        default: return '$duration minuten zonder telefoon';
      }
    }
    const nouns = <String, String>{
      'Reading': 'reading', 'Walking': 'walking', 'Music': 'music',
      'Cooking': 'cooking', 'Exercise': 'movement',
      'Creative activities': 'creating', 'Relaxing': 'relaxing',
      'Spending time with others': 'time together',
    };
    return '$duration minutes of phone free ${nouns[category] ?? 'time'}';
  }

  // The plan stores stable English source strings; translate them only for UI.
  // This keeps SharedPreferences data and kActivities category keys unchanged.
  String planStepText(String value) {
    if (!_nl) return value;
    return _planActivityDutch[value] ?? switch (value) {
      'Prepare for a restful night.' => prepareForRestfulNight,
      'Walk outside for 15 minutes.' => walkOutsideFor15Minutes,
      _ => value,
    };
  }

  String get introDailyStepBody => _nl
      ? 'Elke dag krijg je een kleine telefoonvrije opdracht, zodat er meer ruimte ontstaat voor wat echt belangrijk is.'
      : "Each day, you'll receive one small phone free step to make a little more room for what matters.";
  String get daysUpper => _nl ? 'DAGEN' : 'DAYS';
  String get oneStepAtATime => _nl ? 'Stap voor stap' : 'One step at a time';
  String get introThoughtfulMoments => _nl
      ? 'Kleine, bewuste momenten die passen bij het dagelijks leven.'
      : 'Short, thoughtful moments designed to fit real days.';
  String get introNoPressure => _nl
      ? 'Geen scores of druk. Begin je reis op jouw manier.'
      : 'No scores or pressure. Simply begin your journey as you are.';
  String get letsGo => _nl ? 'Aan de slag' : "Let's go";

  String inProgressLeft(String remaining) => _nl
      ? 'Bezig · nog $remaining' : 'In progress · $remaining left';
  String get openMoment => _nl ? 'Moment openen' : 'Open moment';
  String get startTodaysMoment => _nl ? 'Start het moment van vandaag' : "Start today's moment";
  String get adjustTodaysGoal => _nl ? 'Pas je doel voor vandaag aan' : "Adjust today's goal";
  String get chooseGoalToday => _nl ? 'Kies wat vandaag bij je past' : 'Choose what works for you today';
  String get setOwnTime => _nl ? 'Stel je eigen tijd in' : 'Set your own time';
  String get customTimeRange => _nl ? 'Tussen 15 minuten en 3 uur' : 'Between 15 min and 3 h';
  String yourCustomTime(String duration) => _nl
      ? 'Jouw tijd: $duration · wijzigen' : 'Your time: $duration · change';
  String shortHours(int count) => _nl ? '$count u' : '$count h';
  String shortDuration(int mins) {
    if (mins < 60) return '$mins min';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? shortHours(h) : '${shortHours(h)} $m min';
  }
  String saveDuration(String duration) => _nl ? '$duration opslaan' : 'Save $duration';

  String get momentMadeUpper => _nl ? 'EEN MOMENT VOOR JEZELF' : 'A MOMENT MADE';
  String dayComplete(int day) => _nl ? 'Dag $day voltooid' : 'Day $day complete';
  String phoneFreeToday(int duration) => _nl
      ? 'Je was vandaag $duration minuten telefoonvrij.'
      : 'You spent $duration minutes phone-free today.';
  String get planFinished => _nl
      ? 'Je hebt je hele plan afgerond. Goed gedaan.'
      : "You've reached the end of your plan. Well done.";
  String get nextStepTomorrow => _nl
      ? 'Morgen staat je volgende kleine stap klaar.'
      : 'Your next small step will be ready tomorrow.';
  String get nothingElseToday => _nl
      ? 'Voor nu hoef je niets meer te doen.'
      : "For now, there's nothing more to do.";
  String upNextDay(int day) => _nl ? 'HIERNA · DAG $day' : 'UP NEXT · DAY $day';
  String availableInDays(int daysAway) => _nl
      ? 'BESCHIKBAAR OVER $daysAway ${daysAway == 1 ? 'DAG' : 'DAGEN'}'
      : 'AVAILABLE IN $daysAway ${daysAway == 1 ? 'DAY' : 'DAYS'}';
  String get futureStepInfo => _nl
      ? 'Richt je voorlopig op vandaag. Deze stap wordt beschikbaar als het zover is.'
      : "For now, stay with today. This step will open when it's time.";
  String get completedGentlyUpper => _nl ? 'RUSTIG VOLTOOID' : 'COMPLETED GENTLY';
  String get notCompletedUpper => _nl ? 'NIET VOLTOOID' : 'NOT COMPLETED';
  String get freshStart => _nl
      ? 'Geen probleem. Elke dag is een nieuw begin.'
      : "That's okay. Every day is a fresh start.";

  String todayActivityUpper(int day) => _nl
      ? 'DAG $day · ACTIVITEIT VAN VANDAAG'
      : "DAY $day TODAY'S ACTIVITY";
  String localizedTimeOfDay(String value) {
    if (!_nl) return value;
    switch (value.trim().toLowerCase()) {
      case 'morning': return 'Ochtend';
      case 'afternoon': return 'Middag';
      case 'evening': return 'Avond';
      case 'before bed':
      case 'before sleep': return 'Voor het slapen';
      case 'night': return 'Nacht';
      default: return value;
    }
  }
  String phoneInBoxRunning(String boxName) => _nl
      ? 'Laat je telefoon in de $boxName liggen tot de tijd om is. Je moment loopt door als je teruggaat.'
      : 'Leave your phone in $boxName until the time is up. Your moment keeps running if you go back.';
  String phoneInBoxBeforeStart(String boxName) => _nl
      ? 'Leg je telefoon in de $boxName. De tijd gaat lopen zodra je telefoon erin ligt.'
      : 'Leave your phone in $boxName. Your minutes begin as soon as it is inside.';
  String boxAutomaticStart(String boxName) => _nl
      ? 'Met de $boxName start dit automatisch zodra je je telefoon erin legt.'
      : 'With the $boxName box, this starts automatically when you place your phone inside.';
  String get startTheMoment => _nl ? 'Start het moment' : 'Start the moment';
  String get imDone => _nl ? 'Ik ben klaar' : "I'm done";
  String get cancelThisMoment => _nl ? 'Dit moment annuleren' : 'Cancel this moment';

  String get completedUpper => _nl ? 'VOLTOOID' : 'COMPLETED';
  String get todaysChallengeUpper => _nl ? 'UITDAGING VAN VANDAAG' : "TODAY'S CHALLENGE";
  String get wellDoneMadeTime => _nl
      ? 'Je hebt tijd voor jezelf gemaakt. Goed gedaan.'
      : 'You made time for yourself. Well done.';
  String get startActivity => _nl ? 'Activiteit starten' : 'Start activity';
  String get changeTime => _nl ? 'Tijd wijzigen' : 'Change time';
  List<String> get dailyTips => _nl
      ? const [
          'Leg je telefoon in een andere kamer terwijl je dit doet.',
          'Even zonder telefoon geeft ruimte voor meer.',
          'Leg iets leuks op de plek waar je normaal je telefoon bewaart.',
          'Begin klein. Een rustig moment is net zo waardevol als een lang moment.',
          'Schakel Niet storen in voordat je begint.',
          'Sta stil bij hoe je je voelt als je klaar bent.',
        ]
      : const [
          'Put your phone in another room while you do this.',
          'A little time away makes room for more.',
          'Keep something nice where you usually keep your phone.',
          'Start small. A slow moment counts as much as a long one.',
          'Turn on Do Not Disturb before you begin.',
          'Notice how you feel when you are done.',
        ];

}

// Translation lookup for the 32 activities defined in plan_service.dart.
// Keys must match the English Activity.title and Activity.description exactly.
const Map<String, String> _planActivityDutch = {
  'Read a few pages': 'Lees een paar pagina’s',
  'Pick a book you enjoy and read without your phone nearby.': 'Kies een boek dat je leuk vindt en lees zonder je telefoon in de buurt.',
  'Read something new': 'Lees iets nieuws',
  'Try a short story or a chapter from a book you have not opened yet.': 'Probeer een kort verhaal of een hoofdstuk uit een boek dat je nog niet hebt gelezen.',
  'Reread a favorite': 'Herlees een favoriet',
  'Return to a passage you love and enjoy it slowly.': 'Lees een favoriete passage opnieuw en neem er rustig de tijd voor.',
  'Read by soft light': 'Lees bij zacht licht',
  'Find a cozy spot with warm light and read quietly.': 'Zoek een fijne plek met warm licht en lees in alle rust.',
  'Easy walk outside': 'Maak een ontspannen wandeling',
  'Leave your phone at home or in a bag and notice your surroundings.': 'Laat je telefoon thuis of stop hem in je tas en let op je omgeving.',
  'Walk to a new place': 'Wandel naar een nieuwe plek',
  'Choose a street or park you have not visited recently.': 'Kies een straat of park waar je de laatste tijd niet bent geweest.',
  'Slow mindful walk': 'Maak een bewuste wandeling',
  'Walk slowly and pay attention to sounds and smells.': 'Wandel rustig en let op de geluiden en geuren om je heen.',
  'Walk with someone': 'Wandel samen met iemand',
  'Invite a friend or family member for a phone-free stroll.': 'Nodig een vriend of familielid uit voor een wandeling zonder telefoon.',
  'Listen to an album': 'Luister naar een album',
  'Play a full album from start to finish and just listen.': 'Zet een heel album op, van begin tot eind, en luister aandachtig.',
  'Play an instrument': 'Bespeel een instrument',
  'Pick up an instrument and play anything that feels good.': 'Pak een instrument en speel waar je zin in hebt.',
  'Discover new music': 'Ontdek nieuwe muziek',
  'Put on music you have never heard and see how it feels.': 'Zet muziek op die je nog niet kent en ontdek wat het met je doet.',
  'Sing along': 'Zing mee',
  'Choose songs you love and sing without any screen.': 'Kies liedjes die je mooi vindt en zing mee zonder scherm.',
  'Cook a simple meal': 'Kook een eenvoudige maaltijd',
  'Make something easy and enjoy each step of it.': 'Maak iets eenvoudigs en geniet van elke stap.',
  'Try a new recipe': 'Probeer een nieuw recept',
  'Follow a printed or remembered recipe instead of a screen.': 'Gebruik een afgedrukt recept of een recept uit je hoofd in plaats van een scherm.',
  'Prepare a snack': 'Maak een tussendoortje',
  'Make a small snack slowly and eat it mindfully.': 'Maak rustig een klein tussendoortje en eet het met aandacht op.',
  'Bake something': 'Bak iets lekkers',
  'Bake bread, cookies or anything warm and comforting.': 'Bak brood, koekjes of iets anders waar je blij van wordt.',
  'Gentle stretching': 'Rek en strek rustig',
  'Stretch your body slowly and breathe deeply.': 'Rek je lichaam rustig uit en adem diep in en uit.',
  'Short workout': 'Doe een korte training',
  'Do a simple routine you already know at your own pace.': 'Doe een eenvoudige training die je al kent, in je eigen tempo.',
  'Yoga flow': 'Doe een yogareeks',
  'Move through a few poses that feel calming.': 'Doe een paar yogahoudingen waar je rustig van wordt.',
  'Bodyweight circuit': 'Doe een training met lichaamsgewicht',
  'A few rounds of squats, push-ups and planks.': 'Doe een paar rondes squats, push-ups en plankoefeningen.',
  'Draw or doodle': 'Teken of krabbel wat',
  'Grab paper and a pen and draw whatever comes to mind.': 'Pak papier en een pen en teken wat er in je opkomt.',
  'Write freely': 'Schrijf vrijuit',
  'Write in a notebook for a few minutes without editing.': 'Schrijf een paar minuten in een notitieboek zonder iets te verbeteren.',
  'Make something by hand': 'Maak iets met je handen',
  'Craft, paint or build something small.': 'Knutsel, schilder of bouw iets kleins.',
  'Photograph with intention': 'Fotografeer met aandacht',
  'Look for beauty around you and notice details.': 'Zoek naar mooie dingen om je heen en let op de details.',
  'Quiet sit': 'Zit even in stilte',
  'Sit comfortably, breathe slowly and let your mind settle.': 'Ga comfortabel zitten, adem rustig en laat je gedachten tot rust komen.',
  'Warm drink break': 'Neem pauze met een warm drankje',
  'Make tea or coffee and enjoy it without distractions.': 'Zet thee of koffie en geniet ervan zonder afleiding.',
  'Lie down and rest': 'Ga even liggen en rust uit',
  'Close your eyes and rest, no screens and no pressure.': 'Sluit je ogen en rust uit, zonder schermen en zonder druk.',
  'Gentle breathing': 'Adem rustig',
  'Try slow breathing: in for 4, out for 6.': 'Adem rustig in gedurende 4 tellen en uit gedurende 6 tellen.',
  'Have a real conversation': 'Voer een echt gesprek',
  'Talk with someone close to you, phones away.': 'Praat met iemand die je dierbaar is en leg de telefoons weg.',
  'Share a meal': 'Eet samen',
  'Eat together and keep phones off the table.': 'Eet samen en houd de telefoons van tafel.',
  'Play a game together': 'Speel samen een spel',
  'A board game or cards, anything social and screen-free.': 'Speel een bord- of kaartspel, of iets anders gezelligs zonder scherm.',
  'Call or visit someone': 'Bel of bezoek iemand',
  'Reach out to someone you have been meaning to see.': 'Neem contact op met iemand die je al een tijdje wilt spreken of bezoeken.',
};
