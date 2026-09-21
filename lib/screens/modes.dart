import 'package:flutter/material.dart';

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
          _ModeTile(color: modeColor, icon: Icons.work_outline, label: 'Focus'),
          _ModeTile(
            color: modeColor,
            icon: Icons.school_outlined,
            label: 'Reading',
          ),
          _ModeTile(color: modeColor, icon: Icons.wb_twilight_rounded, label: 'Evening'),
          _ModeTile(color: modeColor, icon: Icons.sunny, label: 'Morning'),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _ModeTile({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon),
          Text(label),
          const Icon(Icons.keyboard_arrow_right),
        ],
      ),
    );
  }
}
