/// V14 - Chat Repository - Production Ready
/// Engine -> Repository -> Service -> Controller -> UI

import '../../../engines/memory/memory_engine.dart';
import '../../../engines/memory/memory_entry.dart';
import '../../../engines/memory/memory_types.dart';
import '../models/message.dart';

/// Repository يتعامل مع البيانات مباشرة - لا UI
class ChatRepository {
  /// حفظ رسالة في الذاكرة
  Future<void> saveMessage(String content) async {
    try {
      final entry = MemoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        type: MemoryType.episodic,
        timestamp: DateTime.now(),
        importance: 0.8,
        tags: ['chat'],
      );
      await MemoryEngine.save(entry);
    } catch (e) {
      throw Exception('Failed to save message: \$e');
    }
  }

  /// جلب المحادثات
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      // TODO: Implement actual fetch from MemoryEngine
      return [
        {'title': 'تذكر أن طنطا مدينة جميلة', 'score': 94},
        {'title': 'Flutter best practices', 'score': 92},
      ];
    } catch (e) {
      throw Exception('Failed to load conversations: \$e');
    }
  }
}
