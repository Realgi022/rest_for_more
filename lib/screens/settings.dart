import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_language.dart';
import '../services/time_format_controller.dart';
import '../theme/app_card.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: ListView(
          children: [
            Text(t.settings, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 24),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: t.blockedApps,
              description: t.blockedAppsDescription,
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onTap: () {
                context.go('/settings/blocked-apps');
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeController,
              builder: (context, themeMode, child) {
                final nightModeOn = themeMode == ThemeMode.dark;

                return _SettingsTile(
                  icon: nightModeOn
                      ? Icons.dark_mode
                      : Icons.dark_mode_outlined,
                  title: t.nightMode,
                  description: t.nightModeDescription,
                  trailing: Switch(
                    value: nightModeOn,
                    onChanged: (value) {
                      themeController.setNightMode(value);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: timeFormatController,
              builder: (context, use24HourTime, child) => _SettingsTile(
                icon: Icons.access_time,
                title: t.timeFormatTitle,
                description: t.timeFormatDescription,
                trailing: DropdownButton<bool>(
                  value: use24HourTime,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: false, child: Text('AM/PM')),
                    DropdownMenuItem(value: true, child: Text('00–23')),
                  ],
                  onChanged: (value) {
                    if (value != null) timeFormatController.setUse24HourTime(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<AppLanguage>(
              valueListenable: appLanguageController,
              builder: (context, language, child) {
                return _SettingsTile(
                  icon: Icons.language,
                  title: t.languageTitle,
                  description: t.languageDescription,
                  trailing: DropdownButton<AppLanguage>(
                    value: language,
                    underline: const SizedBox.shrink(),
                    items: AppLanguage.values
                        .map(
                          (language) => DropdownMenuItem(
                            value: language,
                            child: Text(language.label),
                          ),
                        )
                        .toList(),
                    onChanged: (language) {
                      if (language != null) {
                        appLanguageController.setLanguage(language);
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      borderRadius: BorderRadius.circular(appCardRadius),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: appCardDecoration(context),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(description, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}
