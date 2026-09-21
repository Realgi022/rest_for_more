import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.gutter),
      child: Center(
        child: Text('Today', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
