import 'package:flutter/material.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Today', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
