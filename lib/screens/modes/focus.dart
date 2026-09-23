import 'dart:typed_data';

import 'package:app_blocker/app_blocker.dart';
import 'package:circle_time_progress/circle_time_progress.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/timer_service.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  final AppBlocker _blocker = AppBlocker.instance;

  List<AppInfo> _apps = [];
  Set<String> _selectedApps = {};

  bool _loadingApps = false;

  String formatTime(Duration duration) {
    final hours = duration.inHours;

    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  Future<void> _loadApps() async {
    setState(() {
      _loadingApps = true;
    });

    try {
      final apps = await _blocker.getApps();

      apps.sort(
        (a, b) => a.appName.toLowerCase().compareTo(
          b.appName.toLowerCase(),
        ),
      );

      if (!mounted) return;

      setState(() {
        _apps = apps;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load apps: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingApps = false;
        });
      }
    }
  }

  Future<void> _selectApps() async {
    if (_apps.isEmpty) {
      await _loadApps();
    }

    if (!mounted) return;

    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AppPickerSheet(
          apps: _apps,
          selectedApps: _selectedApps,
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedApps = selected;
      });
    }
  }

  Future<void> _startFocus() async {
    final timer = FocusTimerService.instance;

    // No apps selected -> normal focus timer.
    if (_selectedApps.isEmpty) {
      timer.startTimer();
      return;
    }

    try {
      var permission = await _blocker.checkPermission();

      if (permission != BlockerPermissionStatus.granted) {
        await _blocker.requestPermission();

        permission = await _blocker.checkPermission();
      }

      if (permission != BlockerPermissionStatus.granted) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'App blocking permission is required. '
              'Enable it in Android settings and press Start focus again.',
            ),
          ),
        );

        return;
      }

      await _blocker.blockApps(
        _selectedApps.toList(),
      );

      timer.startTimer();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not start app blocking: $e',
          ),
        ),
      );
    }
  }

  Future<void> confirmStop(BuildContext context) async {
    final timer = FocusTimerService.instance;

    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Stop focus mode?'),
          content: const Text(
            'Your current timer will be cancelled.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Stop'),
            ),
          ],
        );
      },
    );

    if (shouldStop == true) {
      timer.stopTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timer = FocusTimerService.instance;

    return ListenableBuilder(
      listenable: timer,
      builder: (context, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.go('/modes');
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      'Focus',
                      style:
                          theme.textTheme.headlineMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (!timer.timerStarted)
                  _TimerSetupCard(
                    timer: timer,
                    selectedApps:
                        _selectedApps.length,
                    loadingApps: _loadingApps,
                    onSelectApps: _selectApps,
                    onStart: _startFocus,
                  ),

                if (timer.timerStarted)
                  _ActiveTimerCard(
                    timer: timer,
                    formattedTime: formatTime(
                      timer.remaining,
                    ),
                    onStop: () =>
                        confirmStop(context),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerSetupCard extends StatelessWidget {
  final FocusTimerService timer;

  final int selectedApps;
  final bool loadingApps;

  final VoidCallback onSelectApps;
  final VoidCallback onStart;

  const _TimerSetupCard({
    required this.timer,
    required this.selectedApps,
    required this.loadingApps,
    required this.onSelectApps,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary
            .withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface
              .withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary
                      .withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus timer',
                      style:
                          theme.textTheme.titleMedium,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Choose how long you want to focus.',
                      style:
                          theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(
            '${timer.selectedMinutes} min',
            style: theme.textTheme.headlineMedium
                ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Slider(
            min: 5,
            max: 120,
            divisions: 23,
            value:
                timer.selectedMinutes.toDouble(),
            label:
                '${timer.selectedMinutes} min',
            onChanged: (value) {
              timer.setMinutes(value.round());
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: loadingApps
                  ? null
                  : onSelectApps,
              icon: loadingApps
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.apps),
              label: Text(
                selectedApps == 0
                    ? 'Choose blocked apps'
                    : '$selectedApps apps selected',
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStart,
              icon:
                  const Icon(Icons.play_arrow),
              label:
                  const Text('Start focus'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTimerCard extends StatelessWidget {
  final FocusTimerService timer;
  final String formattedTime;
  final VoidCallback onStop;

  const _ActiveTimerCard({
    required this.timer,
    required this.formattedTime,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalSeconds =
        timer.selectedMinutes * 60;

    final progress = totalSeconds == 0
        ? 0.0
        : (timer.remaining.inSeconds /
                totalSeconds)
            .clamp(0.0, 1.0)
            .toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary
            .withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface
              .withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary
                      .withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  timer.isPaused
                      ? Icons.pause
                      : Icons.timer_outlined,
                  color:
                      theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      timer.isPaused
                          ? 'Focus paused'
                          : 'Focus active',
                      style:
                          theme.textTheme.titleMedium,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      timer.isPaused
                          ? 'Resume when you are ready.'
                          : 'Stay focused until the timer ends.',
                      style:
                          theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Stack(
            alignment: Alignment.center,
            children: [
              GradientCircularProgressIndicator(
                value: progress,
                size: 180,
                strokeWidth: 12,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                backgroundColor:
                    theme.colorScheme.onSurface
                        .withValues(alpha: 0.10),
              ),

              Column(
                children: [
                  Text(
                    formattedTime,
                    style: theme
                        .textTheme.headlineMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    timer.isPaused
                        ? 'Paused'
                        : 'Remaining',
                    style:
                        theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: timer.isRunning
                ? FilledButton.icon(
                    onPressed:
                        timer.pauseTimer,
                    icon:
                        const Icon(Icons.pause),
                    label:
                        const Text('Pause'),
                  )
                : FilledButton.icon(
                    onPressed:
                        timer.resumeTimer,
                    icon: const Icon(
                      Icons.play_arrow,
                    ),
                    label:
                        const Text('Resume'),
                  ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onStop,
              icon: const Icon(
                Icons.stop_outlined,
              ),
              label:
                  const Text('Stop focus'),
            ),
          ),
        ],
      ),
    );
  }
}

class AppPickerSheet extends StatefulWidget {
  final List<AppInfo> apps;
  final Set<String> selectedApps;

  const AppPickerSheet({
    super.key,
    required this.apps,
    required this.selectedApps,
  });

  @override
  State<AppPickerSheet> createState() =>
      _AppPickerSheetState();
}

class _AppPickerSheetState
    extends State<AppPickerSheet> {
  late Set<String> _selectedApps;

  String _search = '';

  @override
  void initState() {
    super.initState();

    _selectedApps =
        Set<String>.from(widget.selectedApps);
  }

  void _toggleApp(String packageName) {
    setState(() {
      if (_selectedApps.contains(packageName)) {
        _selectedApps.remove(packageName);
      } else {
        _selectedApps.add(packageName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredApps = widget.apps.where(
      (app) {
        return app.appName
            .toLowerCase()
            .contains(_search.toLowerCase());
      },
    ).toList();

    return Container(
      height:
          MediaQuery.of(context).size.height *
              0.82,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            16,
          ),
          child: Column(
            children: [
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: theme
                      .colorScheme.onSurface
                      .withValues(alpha: 0.20),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Choose blocked apps',
                style: theme
                    .textTheme.titleLarge
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${_selectedApps.length} selected',
                style:
                    theme.textTheme.bodySmall,
              ),

              const SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Search apps',
                  prefixIcon: const Icon(
                    Icons.search,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _search = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  itemCount:
                      filteredApps.length,
                  itemBuilder:
                      (context, index) {
                    final app =
                        filteredApps[index];

                    final selected =
                        _selectedApps.contains(
                      app.packageName,
                    );

                    return ListTile(
                      contentPadding:
                          EdgeInsets.zero,

                      leading: _AppIcon(
                        icon: app.icon,
                      ),

                      title: Text(
                        app.appName,
                        maxLines: 1,
                        overflow: TextOverflow
                            .ellipsis,
                      ),

                      trailing: Checkbox(
                        value: selected,
                        onChanged: (_) {
                          _toggleApp(
                            app.packageName,
                          );
                        },
                      ),

                      onTap: () {
                        _toggleApp(
                          app.packageName,
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _selectedApps,
                    );
                  },
                  child: Text(
                    _selectedApps.isEmpty
                        ? 'Done'
                        : 'Done (${_selectedApps.length})',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  final Uint8List? icon;

  const _AppIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(10),
        child: Image.memory(
          icon!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: const Icon(Icons.apps),
    );
  }
}