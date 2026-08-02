import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

/// V12.1 - Message Input - 60px - Glass - Auto Expand 5 lines
class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isArabic;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onMic;
  final VoidCallback onSearch;
  final Function(String) onSubmitted;

  const MessageInput({
    super.key,
    required this.controller,
    required this.isArabic,
    required this.onSend,
    required this.onAttach,
    required this.onMic,
    required this.onSearch,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 12, top: 12),
      decoration: BoxDecoration(color: AppTheme.deepBlack.withOpacity(0.95), border: Border(top: BorderSide(color: AppTheme.glassBorder.withOpacity(0.5)))),
      child: Row(
        children: [
          IconButton(onPressed: onAttach, icon: const Icon(Icons.attach_file, size: 18), color: Colors.white.withOpacity(0.7), style: IconButton.styleFrom(backgroundColor: AppTheme.glassBg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(width: 6),
          IconButton(onPressed: onMic, icon: const Icon(Icons.mic_none, size: 18), color: Colors.white.withOpacity(0.7), style: IconButton.styleFrom(backgroundColor: AppTheme.glassBg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              decoration: AppTheme.glassDecorationWithRadius(24),
              child: TextField(
                controller: controller,
                maxLines: 5,
                minLines: 1,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: isArabic ? 'اكتب رسالة إلى AI CORE...' : 'Message AI CORE...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                onSubmitted: onSubmitted,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(onPressed: onSearch, icon: const Icon(Icons.search, size: 18), color: Colors.white.withOpacity(0.6), style: IconButton.styleFrom(backgroundColor: AppTheme.glassBg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(width: 6),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              return Container(
                decoration: BoxDecoration(gradient: LinearGradient(colors: hasText ? [AppTheme.cyanNeon, AppTheme.purpleNeon] : [AppTheme.glassBg, AppTheme.glassBg]), borderRadius: BorderRadius.circular(12), boxShadow: hasText ? [BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.3), blurRadius: 12)] : null),
                child: IconButton(onPressed: hasText ? onSend : onMic, icon: Icon(hasText ? Icons.send : Icons.mic, size: 18, color: hasText ? Colors.black : Colors.white70)),
              );
            },
          ),
        ],
      ),
    );
  }
}
