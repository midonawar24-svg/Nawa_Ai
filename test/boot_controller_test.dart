import 'package:flutter_test/flutter_test.dart';
import 'package:ai_core_os_v7_98/features/boot/controllers/boot_controller.dart';

void main() {
  group('BootController', () {
    test('initial progress is 0', () {
      final controller = BootController();
      expect(controller.progress, 0.0);
      controller.dispose();
    });

    test('engines list not empty', () {
      final controller = BootController();
      expect(controller.engines, isNotEmpty);
      controller.dispose();
    });
  });
}
