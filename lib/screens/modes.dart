import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_language.dart';
import '../theme/app_spacing.dart';

class ModesScreen extends StatelessWidget {
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.modes, style: theme.textTheme.headlineMedium),

            const SizedBox(height: 24),

            _ModeTile(
              icon: Icons.work_outline,
              label: t.focus,
              description: t.focusDescription,
              onTap: () {
                context.go('/modes/focus');
              },
            ),

            const SizedBox(height: 12),

            _ModeTile(
              icon: Icons.menu_book_outlined,
              label: t.reading,
              description: t.readingDescription,
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _ModeTile(
              icon: Icons.wb_twilight_outlined,
              label: t.evening,
              description: t.eveningDescription,
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _ModeTile(
              icon: Icons.wb_sunny_outlined,
              label: t.morning,
              description: t.morningDescription,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback? onTap;

  const _ModeTile({
    required this.icon,
    required this.label,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashFactory: NoSplash.splashFactory,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          // color: theme.cardTheme.color,
          color: theme.colorScheme.secondary.withValues(alpha: 0.16),
          // color: theme.colorScheme.secondary.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.10),
          ),
        ),
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
                  Text(label, style: theme.textTheme.titleMedium),

                  const SizedBox(height: 4),

                  Text(description, style: theme.textTheme.bodySmall),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Icon(
              Icons.keyboard_arrow_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
