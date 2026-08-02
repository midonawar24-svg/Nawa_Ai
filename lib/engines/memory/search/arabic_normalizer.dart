class ArabicNormalizer {
  static final _tashkeelRegex = RegExp(r'[\u064B-\u065F\u0670\u0640]');
  static final _alefRegex = RegExp(r'[أإآا]');
  static final _taMarbutaRegex = RegExp(r'ة');
  static final _yaRegex = RegExp(r'ى');
  static final _wawRegex = RegExp(r'ؤ');
  static final _yaHamzaRegex = RegExp(r'ئ');

  static String normalize(String text) {
    if (text.isEmpty) return text;
    var n = text;
    n = n.replaceAll(_tashkeelRegex, '');
    n = n.replaceAll(_alefRegex, 'ا');
    n = n.replaceAll(_taMarbutaRegex, 'ه');
    n = n.replaceAll(_yaRegex, 'ي');
    n = n.replaceAll(_wawRegex, 'و');
    n = n.replaceAll(_yaHamzaRegex, 'ي');
    return n.toLowerCase().trim();
  }

  static List<String> tokenize(String text) {
    final normalized = normalize(text);
    return normalized.split(RegExp(r'[^a-z0-9\u0621-\u064A]+')).where((s) => s.length > 1).toList();
  }

  static String lightNormalize(String text) => text.replaceAll(_tashkeelRegex, '').toLowerCase().trim();
}
