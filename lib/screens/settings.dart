import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 24),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeController,
              builder: (context, themeMode, child) {
                final nightModeOn = themeMode == ThemeMode.dark;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.10,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.18,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          nightModeOn
                              ? Icons.dark_mode
                              : Icons.dark_mode_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Night Mode',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use darker colors for late-night rest.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: nightModeOn,
                        onChanged: (value) {
                          themeController.setNightMode(value);
                        },
                      ),
                    ],
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
