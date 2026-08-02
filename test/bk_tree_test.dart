import 'package:flutter_test/flutter_test.dart';
import 'package:ai_smart_phone/engines/memory/search/bk_tree.dart';
import 'package:ai_smart_phone/engines/memory/search/text_utils.dart';

void main() {
  test('BK-Tree exact', () {
    final tree = BKTree((a,b) => TextUtils.levenshtein(a, b));
    tree.add('محمد'); tree.add('احمد');
    expect(tree.search('محمد', 0), contains('محمد'));
  });
  test('BK-Tree fuzzy', () {
    final tree = BKTree((a,b) => TextUtils.levenshtein(a, b));
    tree.add('محمد'); tree.add('احمد');
    final results = tree.search('محمم', 1);
    expect(results.contains('محمد'), true);
  });
  test('Levenshtein', () {
    expect(TextUtils.levenshtein('محمد', 'محمد'), 0);
    expect(TextUtils.levenshtein('test', 'testt'), 1);
  });
}
