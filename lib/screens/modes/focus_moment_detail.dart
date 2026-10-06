import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FocusMomentScreen extends StatefulWidget {
  const FocusMomentScreen({super.key});

  @override
  State<FocusMomentScreen> createState() => _FocusMomentScreenState();
}

class _FocusMomentScreenState extends State<FocusMomentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Focus', style: GoogleFonts.CormorantGaramond(fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'This is the Focus Moment screen. Here you can manage your focus sessions and view details about your focus moments.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          )
        ),
      ),
    );
  }
}