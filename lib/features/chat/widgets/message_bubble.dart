import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

/// V12.1 - Message Bubble - Glass Effect
class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isArabic;

  const MessageBubble({super.key, required this.text, required this.isUser, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.cyanNeon.withOpacity(0.15) : AppTheme.glassBg,
          borderRadius: BorderRadius.circular(20).copyWith(bottomRight: isUser ? const Radius.circular(4) : null, bottomLeft: !isUser ? const Radius.circular(4) : null),
          border: Border.all(color: isUser ? AppTheme.cyanNeon.withOpacity(0.3) : AppTheme.glassBorder),
        ),
        child: Text(text, style: TextStyle(fontSize: 13.5, color: Colors.white.withOpacity(0.9), height: 1.5), textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr),
      ),
    );
  }
}
