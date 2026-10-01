import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_spacing.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Text('Mo'), 
              Text('Tu'), 
              Text('We'), 
              Text('Th'), 
              Text('Fr'), 
              Text('Sa'),
              Text('Su'),
            ],
          ),
        ],
      ),
    );
  }
}
