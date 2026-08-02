import 'package:flutter_test/flutter_test.dart';
import 'package:ai_smart_phone/engines/database/database_engine.dart';

void main() {
  setUp(() async { await DatabaseEngine.instance.initialize(); await DatabaseEngine.instance.clearAll(); });

  test('Insert and query', () async {
    final id = await DatabaseEngine.instance.insert('test_table', {'name': 'test'});
    expect(id.isNotEmpty, true);
    final rows = await DatabaseEngine.instance.query('test_table');
    expect(rows.length, 1);
  });

  test('queryById', () async {
    final id = await DatabaseEngine.instance.insert('test_table', {'name': 'test'});
    final row = await DatabaseEngine.instance.queryById('test_table', id);
    expect(row?['name'], 'test');
  });

  test('Update preserves createdAt', () async {
    final id = await DatabaseEngine.instance.insert('test_table', {'name': 'test', 'createdAt': '2020-01-01'});
    await DatabaseEngine.instance.update('test_table', id, {'name': 'updated'});
    final row = await DatabaseEngine.instance.queryById('test_table', id);
    expect(row?['createdAt'], '2020-01-01');
    expect(row?['name'], 'updated');
  });

  test('Delete', () async {
    final id = await DatabaseEngine.instance.insert('test_table', {'name': 'test'});
    expect(await DatabaseEngine.instance.delete('test_table', id), true);
    final rows = await DatabaseEngine.instance.query('test_table');
    expect(rows.isEmpty, true);
  });

  test('Where filter', () async {
    await DatabaseEngine.instance.insert('test_table', {'type': 'a'});
    await DatabaseEngine.instance.insert('test_table', {'type': 'b'});
    final filtered = await DatabaseEngine.instance.query('test_table', where: {'type': 'a'});
    expect(filtered.length, 1);
  });

  test('Concurrent insert', () async {
    final futures = List.generate(10, (i) => DatabaseEngine.instance.insert('test_table', {'i': i}));
    final ids = await Future.wait(futures);
    expect(ids.length, 10);
    final count = await DatabaseEngine.instance.count('test_table');
    expect(count, 10);
  });
}
