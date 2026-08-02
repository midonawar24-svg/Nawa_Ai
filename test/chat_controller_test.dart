import 'package:flutter_test/flutter_test.dart';
import 'package:ai_core_os_v7_98/features/chat/controllers/chat_controller.dart';

/// V14 - Tests - Production Ready
void main() {
  group('ChatController', () {
    late ChatController controller;

    setUp(() {
      controller = ChatController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is correct', () {
      expect(controller.messages, isEmpty);
      expect(controller.isTyping, isFalse);
      expect(controller.aiStatus, 'Ready');
    });

    test('toggleLanguage changes isArabic', () {
      final initial = controller.isArabic;
      controller.toggleLanguage();
      expect(controller.isArabic, isNot(initial));
    });

    test('sendMessage adds user message', () async {
      await controller.sendMessage('Hello');
      expect(controller.messages.length, greaterThan(0));
      expect(controller.messages.first['role'], 'user');
    });
  });
}
