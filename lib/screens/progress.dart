import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_typography.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      body: Column(
        children: [
          Row( mainAxisAlignment:MainAxisAlignment.spaceEvenly,
            children: [
              Text('Mo'), 
              Text('Tu'), 
              Text('We'), 
              Text('Th'), 
              Text('Fr'), 
              Text('Sa'),
              Text('Su'),
              Spacer(),
              IconButton(
                onPressed: () {
                  context.go('/calendar');
                },
                icon: Icon(Icons.calendar_month)
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Today',
                  style: appTextTheme.headlineMedium,
              ),
              Spacer(),
              Text (today.toString().substring(0, 10),
                style: appTextTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
