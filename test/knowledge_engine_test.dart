import 'package:flutter_test/flutter_test.dart';
import 'package:ai_smart_phone/engines/knowledge/knowledge_engine.dart';
import 'package:ai_smart_phone/engines/database/database_engine.dart';

void main() {
  setUp(() async { await DatabaseEngine.instance.initialize(); await KnowledgeEngine.instance.initialize(); await KnowledgeEngine.instance.clear(); });

  test('Add and search', () async {
    await KnowledgeEngine.instance.addKnowledge('محمد نوار من طنطا', tags: ['شخص', 'طنطا']);
    final results = await KnowledgeEngine.instance.search('محمد نوار');
    expect(results.isNotEmpty, true);
  });

  test('Prevent duplicate', () async {
    await KnowledgeEngine.instance.addKnowledge('نفس المحتوى', tags: ['test']);
    await KnowledgeEngine.instance.addKnowledge('نفس المحتوى', tags: ['test']);
    expect(await KnowledgeEngine.instance.count(), 1);
  });

  test('Input validation', () async {
    await expectLater(KnowledgeEngine.instance.addKnowledge(''), throwsArgumentError);
    await expectLater(KnowledgeEngine.instance.addKnowledge('ab'), throwsArgumentError);
  });

  test('Tag index', () async {
    await KnowledgeEngine.instance.addKnowledge('معرفة 1', tags: ['مهم']);
    await KnowledgeEngine.instance.addKnowledge('معرفة 2', tags: ['عادي']);
    final results = await KnowledgeEngine.instance.search('مهم');
    expect(results.isNotEmpty, true);
  });

  test('Remove', () async {
    await KnowledgeEngine.instance.addKnowledge('للحذف', tags: ['test']);
    final all = await KnowledgeEngine.instance.search('للحذف');
    expect(all.isNotEmpty, true);
    await KnowledgeEngine.instance.removeKnowledge(all.first.id);
    expect(await KnowledgeEngine.instance.count(), 0);
  });
}
