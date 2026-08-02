import 'dart:math';
import 'arabic_normalizer.dart';

class TextUtils {
  static int levenshtein(String s, String t, {int maxDistance = 100}) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    if ((s.length - t.length).abs() > maxDistance) return maxDistance + 1;
    if (s.length > t.length) { final tmp = s; s = t; t = tmp; }
    List<int> v0 = List.generate(t.length + 1, (i) => i);
    List<int> v1 = List.filled(t.length + 1, 0);
    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      int minInRow = v1[0];
      for (int j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
        minInRow = min(minInRow, v1[j + 1]);
      }
      if (minInRow > maxDistance) return maxDistance + 1;
      final tmp = v0; v0 = v1; v1 = tmp;
    }
    return v0[t.length];
  }

  static double jaccard(List<String> a, List<String> b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    final setA = a.toSet(); final setB = b.toSet();
    return setA.union(setB).isEmpty ? 0.0 : setA.intersection(setB).length / setA.union(setB).length;
  }

  static Set<String> trigrams(String word) {
    if (word.length < 3) return {word};
    final result = <String>{};
    final normalized = ArabicNormalizer.normalize(word);
    for (int i = 0; i <= normalized.length - 3; i++) result.add(normalized.substring(i, i + 3));
    return result;
  }
}
