import 'package:circle_time_progress/circle_time_progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
            child: Padding(
              padding: EdgeInsets.all(16),
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
  const _Header({super.key});

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
  const _TimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;

    return timer.timerStarted
        ? const _ActiveTimerCard()
        : const _InactiveTimerCard();
  }
}

class _InactiveTimerCard extends StatefulWidget {
  const _InactiveTimerCard({super.key});

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE6DA),
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
              backgroundColor: const Color(0xFF7B563D),
            ),
            child: Text(
              'Start',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: const Color(0xFFFAF8F4),
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
    return Column(
      children: [
        Text(label, style: GoogleFonts.manrope()),

        const SizedBox(height: 8),

        SizedBox(
          width: 80,
          height: 150,
          child: CupertinoPicker(
            scrollController: controller,
            itemExtent: 40,
            onSelectedItemChanged: onChanged,
            children: List.generate(
              maxValue + 1,
              (index) => Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: GoogleFonts.manrope(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
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
        backgroundColor: const Color(0xFFFAF8F4),
      ), 
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(color: const Color(0xFF4E3B31)),
      ),
    );
  }
}

class _ActiveTimerCard extends StatelessWidget {
  const _ActiveTimerCard({super.key});

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
  const _ActivePausedTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = FocusTimerService.instance;
    return timer.isPaused
        ? const _PausedTimerControls()
        : const _ActiveTimerControls();
  }
}

class _ActiveTimerControls extends StatelessWidget {
  const _ActiveTimerControls({super.key});

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
  const _PausedTimerControls({super.key});

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
