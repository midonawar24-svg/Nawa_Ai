import 'package:flutter_test/flutter_test.dart';
import 'package:ai_smart_phone/services/lock_service.dart';

void main() {
  test('Sequential execution', () async {
    final order = <int>[];
    final futures = [
      AppLock.synchronized(() async { await Future.delayed(Duration(milliseconds: 10)); order.add(1); }),
      AppLock.synchronized(() async { order.add(2); }),
      AppLock.synchronized(() async { order.add(3); }),
    ];
    await Future.wait(futures);
    expect(order, [1, 2, 3]);
  });

  test('Concurrent write safety', () async {
    int counter = 0;
    final futures = List.generate(100, (_) => AppLock.synchronized(() async { counter++; }));
    await Future.wait(futures);
    expect(counter, 100);
  });

  test('Exception does not break lock', () async {
    try { await AppLock.synchronized(() async { throw Exception('test'); }); } catch (_) {}
    bool executed = false;
    await AppLock.synchronized(() async { executed = true; });
    expect(executed, true);
  });
}
