import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModesScreen extends StatelessWidget {
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modeColor = Theme.of(context).colorScheme.secondary
        .withValues(alpha: 0.6);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          _ModeTile(color: modeColor, icon: Icons.work_outline, label: 'Focus', onTap: () { context.go('modes/focus'); }),
          _ModeTile(
            color: modeColor,
            icon: Icons.menu_book_outlined,
            label: 'Reading',
          ),
          _ModeTile(color: modeColor, icon: Icons.wb_twilight_outlined, label: 'Evening'),
          _ModeTile(color: modeColor, icon: Icons.wb_sunny_outlined, label: 'Morning'),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ModeTile({
    required this.color,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon),
            Text(label),
            const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }
}
