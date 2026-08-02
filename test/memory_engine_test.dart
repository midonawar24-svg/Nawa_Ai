import 'package:flutter_test/flutter_test.dart';
import 'package:ai_smart_phone/engines/memory/memory_engine.dart';
import 'package:ai_smart_phone/engines/memory/memory_types.dart';
import 'package:ai_smart_phone/engines/memory/memory_query.dart';

void main() {
  setUp(() async { await MemoryEngine.initialize(); await MemoryEngine.clear(); });

  test('Remember and recall with importance', () async {
    await MemoryEngine.remember(type: MemoryType.episodic, content: 'محمد نوار من طنطا', importance: 0.9);
    final results = await MemoryEngine.recall(MemoryQuery(query: 'محمد نوار'));
    expect(results.isNotEmpty, true);
    expect(results.first.entry.importance, 0.9);
  });

  test('Feedback', () async {
    final entry = await MemoryEngine.remember(type: MemoryType.episodic, content: 'test feedback', importance: 0.5);
    await MemoryEngine.provideFeedback(entry.id, 1.0);
    final results = await MemoryEngine.recall(MemoryQuery(query: 'feedback'));
    expect(results.first.entry.feedbackScore > 0, true);
  });

  test('Arabic normalization', () async {
    await MemoryEngine.remember(type: MemoryType.episodic, content: 'مدرسة طنطا', importance: 0.5);
    final results = await MemoryEngine.recall(MemoryQuery(query: 'مدرسه طنطا'));
    expect(results.isNotEmpty, true);
  });

  test('Critical protection', () async {
    await MemoryEngine.remember(type: MemoryType.episodic, content: 'critical', importance: 0.95);
    for (int i = 0; i < 1005; i++) await MemoryEngine.remember(type: MemoryType.episodic, content: 'filler $i', importance: 0.1);
    final criticalSearch = await MemoryEngine.recall(MemoryQuery(query: 'critical'));
    expect(criticalSearch.isNotEmpty, true);
  });
}
