import 'package:flutter_test/flutter_test.dart';
import 'package:ai_smart_phone/engines/memory/search/arabic_normalizer.dart';

void main() {
  test('Arabic normalization - Alef', () {
    expect(ArabicNormalizer.normalize('أحمد'), ArabicNormalizer.normalize('احمد'));
    expect(ArabicNormalizer.normalize('إسلام'), 'اسلام');
  });
  test('Ta Marbuta', () {
    expect(ArabicNormalizer.normalize('مدرسة'), ArabicNormalizer.normalize('مدرسه'));
  });
  test('Tashkeel removal', () {
    expect(ArabicNormalizer.normalize('مُحَمَّد'), 'محمد');
  });
  test('Tokenization', () {
    final tokens = ArabicNormalizer.tokenize('محمد نوار من طنطا');
    expect(tokens.contains('محمد'), true);
  });
}
