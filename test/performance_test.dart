import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:ai_smart_phone/engines/memory/memory_engine.dart';
import 'package:ai_smart_phone/engines/memory/memory_types.dart';
import 'package:ai_smart_phone/engines/memory/memory_query.dart';

void main() {
  setUp(() async { await MemoryEngine.initialize(); await MemoryEngine.clear(); });

  test('Performance 1000 memories', () async {
    final sw = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) await MemoryEngine.remember(type: MemoryType.episodic, content: 'memory $i content with some words', importance: 0.5);
    sw.stop();
    debugPrint('Insert 1000: ${sw.elapsedMilliseconds}ms');

    final sw2 = Stopwatch()..start();
    final results = await MemoryEngine.recall(MemoryQuery(query: 'memory 500', limit: 20));
    sw2.stop();
    debugPrint('Recall from 1000: ${sw2.elapsedMilliseconds}ms - found ${results.length}');
    expect(results.isNotEmpty, true);
    expect(sw2.elapsedMilliseconds < 1000, true);
  }, timeout: Timeout(Duration(seconds: 30)));

  test('BKTree fuzzy performance', () async {
    for (int i = 0; i < 500; i++) await MemoryEngine.remember(type: MemoryType.episodic, content: 'كلمة $i مختلفة', importance: 0.5);
    final sw = Stopwatch()..start();
    final results = await MemoryEngine.recall(MemoryQuery(query: 'كلمه', limit: 20));
    sw.stop();
    debugPrint('Fuzzy search 500 Arabic: ${sw.elapsedMilliseconds}ms - found ${results.length}');
    expect(sw.elapsedMilliseconds < 500, true);
  }, timeout: Timeout(Duration(seconds: 20)));
}
