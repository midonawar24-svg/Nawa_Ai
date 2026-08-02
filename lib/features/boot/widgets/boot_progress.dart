import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

/// V13 - Boot Progress - <50 سطر
class BootProgress extends StatelessWidget {
  final AnimationController controller;
  const BootProgress({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Column(
            children: [
              LinearProgressIndicator(value: controller.value, backgroundColor: Colors.white10, valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cyanNeon)),
              const SizedBox(height: 8),
              Text('Loading AI Core... \${(controller.value * 100).toInt()}%', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
            ],
          );
        },
      ),
    );
  }
}
