import '../engines/memory/search/arabic_normalizer.dart';
import '../engines/memory/search/text_utils.dart';

class ArabicRecognitionService {
  static final Map<String, List<String>> _synonyms = {
    'تذكر': ['احفظ', 'افتكر', 'سجل', 'خزن'],
    'احذف': ['امسح', 'شيل', 'ازالة'],
    'ابحث': ['دور', 'فتش', 'اعثر', 'اين', 'فين'],
    'مدرسة': ['مدرسه', 'المدرسة'],
    'محمد': ['محممد', 'مُحَمَّد'],
  };

  static final Map<String, String> _typos = {
    'مدرسه': 'مدرسة',
    'ذاكره': 'ذاكرة',
    'معرفه': 'معرفة',
    'مصطفي': 'مصطفى',
  };

  static String correctTypos(String text) {
    var corrected = text;
    _typos.forEach((k, v) => corrected = corrected.replaceAll(k, v));
    return corrected;
  }

  static bool isArabic(String text) => RegExp(r'[؀-ۿ]').hasMatch(text);

  static bool isArabicQuestion(String text) {
    final t = text.trim();
    return t.endsWith('؟') || t.startsWith('هل') || t.startsWith('ما') || t.startsWith('ماذا') || t.startsWith('كيف') || t.contains('؟');
  }

  static String detectDialect(String text) {
    final n = text.toLowerCase();
    if (n.contains('ازاي') || n.contains('فين') || n.contains('ايه')) return 'مصري';
    if (n.contains('شلون') || n.contains('وين')) return 'خليجي';
    return 'فصحى';
  }

  static List<String> expandWithSynonyms(String query) {
    final normalized = ArabicNormalizer.normalize(query);
    final tokens = ArabicNormalizer.tokenize(normalized);
    final expanded = <String>{normalized};
    for (final token in tokens) {
      for (final entry in _synonyms.entries) {
        if (ArabicNormalizer.normalize(entry.key) == token) {
          for (final syn in entry.value) {
            expanded.add(normalized.replaceAll(token, ArabicNormalizer.normalize(syn)));
          }
        }
      }
    }
    return expanded.toList();
  }

  static Map<String, dynamic> analyzeArabicText(String text) {
    final normalized = ArabicNormalizer.normalize(text);
    final tokens = ArabicNormalizer.tokenize(text);
    final corrected = correctTypos(text);
    return {
      'original': text,
      'normalized': normalized,
      'tokens': tokens,
      'isArabic': isArabic(text),
      'isQuestion': isArabicQuestion(text),
      'dialect': detectDialect(text),
      'wordCount': tokens.length,
      'hasTypos': corrected != text,
      'corrected': corrected,
    };
  }

  static double arabicSimilarity(String a, String b) {
    final normA = ArabicNormalizer.normalize(a);
    final normB = ArabicNormalizer.normalize(b);
    if (normA == normB) return 1.0;
    final tokensA = ArabicNormalizer.tokenize(normA);
    final tokensB = ArabicNormalizer.tokenize(normB);
    return TextUtils.jaccard(tokensA, tokensB);
  }
}
