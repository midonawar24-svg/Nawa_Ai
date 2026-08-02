import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

/// V12.1 - Typing Indicator - AI CORE is thinking...
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: AppTheme.glassBg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('AI CORE is thinking', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
          const SizedBox(width: 8),
          ...List.generate(3, (i) => Container(margin: EdgeInsets.only(left: i == 0 ? 0 : 4), width: 6, height: 6, decoration: BoxDecoration(color: AppTheme.cyanNeon.withOpacity(0.6), shape: BoxShape.circle))),
        ]),
      ),
    );
  }
}
