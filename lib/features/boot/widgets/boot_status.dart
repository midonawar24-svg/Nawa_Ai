import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

/// V13 - Boot Status - <50 سطر
class BootStatus extends StatelessWidget {
  const BootStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('AI CORE OS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
        const SizedBox(height: 4),
        Text('Personal AI Operating System', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
        const SizedBox(height: 16),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('Neural Link Active', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
        ]),
      ],
    );
  }
}
