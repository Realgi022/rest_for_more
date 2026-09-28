import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/app_blocker_service.dart';
import '../theme/app_spacing.dart';

class BlockedAppsScreen extends StatefulWidget {
  const BlockedAppsScreen({super.key});

  @override
  State<BlockedAppsScreen> createState() => _BlockedAppsScreenState();
}

class _BlockedAppsScreenState extends State<BlockedAppsScreen> {
  var _apps = <InstalledApp>[];
  var _blockedPackages = <String>{};
  var _accessibilityEnabled = false;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        AppBlockerService.getInstalledApps(),
        AppBlockerService.getBlockedPackages(),
        AppBlockerService.isAccessibilityServiceEnabled(),
      ]);

      if (!mounted) return;

      setState(() {
        _apps = results[0] as List<InstalledApp>;
        _blockedPackages = results[1] as Set<String>;
        _accessibilityEnabled = results[2] as bool;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not load installed apps.';
        _loading = false;
      });
    }
  }

  Future<void> _toggleApp(String packageName, bool blocked) async {
    final nextBlockedPackages = Set<String>.from(_blockedPackages);

    if (blocked) {
      nextBlockedPackages.add(packageName);
    } else {
      nextBlockedPackages.remove(packageName);
    }

    setState(() {
      _blockedPackages = nextBlockedPackages;
    });

    await AppBlockerService.setBlockedPackages(nextBlockedPackages);
  }

  Future<void> _openAccessibilitySettings() async {
    await AppBlockerService.openAccessibilitySettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.go('/settings');
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Blocked apps',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!AppBlockerService.isSupported)
              _InfoCard(
                icon: Icons.android,
                title: 'Android only',
                message: 'App blocking is only available on Android devices.',
              )
            else ...[
              _PermissionCard(
                enabled: _accessibilityEnabled,
                onEnable: _openAccessibilitySettings,
                onRefresh: _load,
              ),
              const SizedBox(height: 16),
              Text(
                '${_blockedPackages.length} apps blocked',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _InfoCard(
                  icon: Icons.error_outline,
                  title: 'Something went wrong',
                  message: _error!,
                )
              else if (_apps.isEmpty)
                const _InfoCard(
                  icon: Icons.apps_outlined,
                  title: 'No apps found',
                  message: 'Pull down to refresh the installed apps list.',
                )
              else
                ..._apps.map((app) {
                  final blocked = _blockedPackages.contains(app.packageName);

                  return Card(
                    elevation: 0,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.10,
                        ),
                      ),
                    ),
                    child: SwitchListTile(
                      value: blocked,
                      onChanged: (value) => _toggleApp(app.packageName, value),
                      title: Text(app.label),
                      subtitle: Text(app.packageName),
                      secondary: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.18,
                        ),
                        child: Icon(
                          blocked ? Icons.lock : Icons.lock_open_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final bool enabled;
  final VoidCallback onEnable;
  final VoidCallback onRefresh;

  const _PermissionCard({
    required this.enabled,
    required this.onEnable,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                enabled ? Icons.check_circle : Icons.warning_amber_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  enabled ? 'Blocking is enabled' : 'Enable app blocking',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            enabled ? 'Selected apps will be blocked when opened.' : 'Turn on the Rest For More accessibility service so Android can detect blocked apps.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          if (enabled)
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh status'),
            )
          else
            FilledButton.icon(
              onPressed: onEnable,
              icon: const Icon(Icons.settings_accessibility),
              label: const Text('Open accessibility settings'),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(message, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
