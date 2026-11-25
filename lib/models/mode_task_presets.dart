import 'mode_schedule.dart';
import 'mode_task.dart';

const Map<ModeId, List<ModeTask>> modeTaskPresets = {
  ModeId.focus: [
    ModeTask(
      id: 'focus-deep-work',
      title: 'Deep work',
      description: 'Work on one important task without your phone.',
      durationMinutes: 25,
      isPreset: true,
    ),
    ModeTask(
      id: 'focus-break',
      title: 'Short break',
      description: 'Step away and rest your eyes.',
      durationMinutes: 5,
      isPreset: true,
    ),
  ],
  ModeId.reading: [
    ModeTask(
      id: 'reading-chapter',
      title: 'Read a chapter',
      description: 'Read without keeping your phone nearby.',
      durationMinutes: 20,
      isPreset: true,
    ),
    ModeTask(
      id: 'reading-notes',
      title: 'Write a few notes',
      description: 'Capture what stood out to you.',
      durationMinutes: 5,
      isPreset: true,
    ),
  ],
  ModeId.morning: [
    ModeTask(
      id: 'morning-stretch',
      title: 'Gentle stretching',
      description: 'Stretch slowly and breathe deeply.',
      durationMinutes: 10,
      isPreset: true,
    ),
    ModeTask(
      id: 'morning-plan',
      title: 'Plan your day',
      description: 'Choose one or two priorities for today.',
      durationMinutes: 5,
      isPreset: true,
    ),
  ],
  ModeId.evening: [
    ModeTask(
      id: 'evening-breathe',
      title: 'Slow breathing',
      description: 'Breathe slowly and let the day settle.',
      durationMinutes: 10,
      isPreset: true,
    ),
    ModeTask(
      id: 'evening-journal',
      title: 'Journal',
      description: 'Write down a thought from your day.',
      durationMinutes: 10,
      isPreset: true,
    ),
  ],
};

List<ModeTask> presetsForMode(ModeId modeId) => [
  ...(modeTaskPresets[modeId] ?? const <ModeTask>[]),
];
