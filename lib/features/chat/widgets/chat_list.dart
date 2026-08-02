import 'package:flutter/material.dart';
import 'message_bubble.dart';
import 'typing_indicator.dart';
import 'welcome_screen.dart';

/// V12.1 - Chat List - ListView.builder لدعم آلاف الرسائل
class ChatList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final bool isTyping;
  final bool isArabic;
  final ScrollController scrollController;
  final Function(String) onSuggestionTap;

  const ChatList({
    super.key,
    required this.messages,
    required this.isTyping,
    required this.isArabic,
    required this.scrollController,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty && !isTyping) {
      return WelcomeScreen(isArabic: isArabic, onSuggestionTap: onSuggestionTap);
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isTyping) {
          return const TypingIndicator();
        }
        final msg = messages[index];
        return MessageBubble(text: msg['text'], isUser: msg['role'] == 'user', isArabic: isArabic);
      },
    );
  }
}
