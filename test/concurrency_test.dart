import 'package:flutter_test/flutter_test.dart';
import 'package:ai_smart_phone/engines/memory/memory_engine.dart';
import 'package:ai_smart_phone/engines/memory/memory_types.dart';
import 'package:ai_smart_phone/engines/memory/memory_query.dart';

void main() {
  setUp(() async { await MemoryEngine.initialize(); await MemoryEngine.clear(); });

  test('Concurrent remember', () async {
    final futures = List.generate(50, (i) => MemoryEngine.remember(type: MemoryType.episodic, content: 'memory $i', importance: 0.5));
    final results = await Future.wait(futures);
    expect(results.length, 50);
    expect(await MemoryEngine.count(), 50);
  });

  test('Concurrent remember and recall', () async {
    for (int i = 0; i < 20; i++) await MemoryEngine.remember(type: MemoryType.episodic, content: 'test $i');
    final futures = [
      ...List.generate(10, (i) => MemoryEngine.remember(type: MemoryType.episodic, content: 'new $i')),
      ...List.generate(10, (_) => MemoryEngine.recall(MemoryQuery(query: 'test'))),
    ];
    await Future.wait(futures);
    expect(await MemoryEngine.count() >= 20, true);
  });
}
