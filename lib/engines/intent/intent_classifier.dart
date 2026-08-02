import '../../services/logger_service.dart';
import '../memory/search/arabic_normalizer.dart';

enum IntentType { question, command, memory, chitchat, knowledge, unknown }

class ClassifiedIntent {
  final IntentType type;
  final String raw;
  final double confidence;
  final Map<String, dynamic> entities;
  final List<Map<String, dynamic>> allScores;
  ClassifiedIntent({required this.type, required this.raw, this.confidence = 0.5, this.entities = const {}, this.allScores = const []});
}

class IntentClassifier {
  IntentClassifier._();
  static final IntentClassifier instance = IntentClassifier._();

  final Map<IntentType, List<String>> _keywords = {
    IntentType.question: ['ما', 'ماذا', 'كيف', 'متى', 'هل', 'اين', 'لماذا', 'what', 'how', 'when', 'why', 'where', '؟', '?'],
    IntentType.command: ['اعمل', 'شغل', 'احذف', 'افتح', 'انشئ', 'ابني', 'do', 'create', 'delete', 'build', 'make', 'run'],
    IntentType.memory: ['تذكر', 'احفظ', 'انسى', 'افتكر', 'remember', 'forget', 'recall', 'save'],
    IntentType.knowledge: ['اشرح', 'ما هو', 'عرف', 'وضح', 'explain', 'define', 'tell me about'],
    IntentType.chitchat: ['مرحبا', 'سلام', 'كيفك', 'اهلا', 'هلا', 'hello', 'hi', 'hey'],
  };

  final Map<IntentType, List<RegExp>> _patterns = {
    IntentType.question: [RegExp(r'^(ما|ماذا|كيف|هل|why|what|how)\b', caseSensitive: false), RegExp(r'[؟?]$')],
    IntentType.command: [RegExp(r'^(اعمل|شغل|احذف|افتح|create|delete|build)\b', caseSensitive: false)],
    IntentType.memory: [RegExp(r'\b(تذكر|احفظ|انسى|remember|forget)\b', caseSensitive: false)],
  };

  Future<ClassifiedIntent> classify(String text) async {
    final lower = text.toLowerCase();
    final normalized = ArabicNormalizer.normalize(text);
    final tokens = ArabicNormalizer.tokenize(text);
    final scores = <IntentType, double>{};
    final debugScores = <Map<String, dynamic>>[];
    for (final entry in _keywords.entries) {
      double score = 0.0; int matches = 0;
      for (final kw in entry.value) {
        final normKw = ArabicNormalizer.normalize(kw);
        if (normalized.contains(normKw) || lower.contains(kw.toLowerCase())) {
          matches++; score += tokens.contains(normKw) ? 0.3 : 0.15;
        }
      }
      for (final pattern in _patterns[entry.key] ?? []) { if (pattern.hasMatch(text)) { score += 0.4; matches++; } }
      if (matches > 0) { score = score.clamp(0.0, 1.0); scores[entry.key] = score; debugScores.add({'intent': entry.key.name, 'score': score, 'matches': matches}); }
    }
    IntentType best = IntentType.unknown; double bestScore = 0.0;
    scores.forEach((type, score) { if (score > bestScore) { bestScore = score; best = type; } });
    if (best == IntentType.unknown) {
      if (lower.contains('?') || lower.contains('؟')) { best = IntentType.question; bestScore = 0.6; }
      else if (text.trim().length > 2 && text.trim().length < 20) { best = IntentType.chitchat; bestScore = 0.5; }
    }
    final entities = <String, dynamic>{}; if (tokens.isNotEmpty) { entities['tokens'] = tokens; entities['wordCount'] = tokens.length; }
    return ClassifiedIntent(type: best, raw: text, confidence: bestScore.clamp(0.1, 0.95), entities: entities, allScores: debugScores);
  }

  Future<List<ClassifiedIntent>> classifyTopK(String text, {int k = 3}) async {
    final lower = text.toLowerCase();
    final normalized = ArabicNormalizer.normalize(text);
    final tokens = ArabicNormalizer.tokenize(text);
    final allIntents = <ClassifiedIntent>[];
    for (final entry in _keywords.entries) {
      double score = 0.0; int matches = 0;
      for (final kw in entry.value) {
        final normKw = ArabicNormalizer.normalize(kw);
        if (normalized.contains(normKw) || lower.contains(kw.toLowerCase())) { matches++; score += tokens.contains(normKw) ? 0.3 : 0.15; }
      }
      for (final pattern in _patterns[entry.key] ?? []) { if (pattern.hasMatch(text)) { score += 0.4; matches++; } }
      if (matches > 0) {
        score = score.clamp(0.0, 1.0);
        allIntents.add(ClassifiedIntent(type: entry.key, raw: text, confidence: score.clamp(0.1, 0.95), entities: {'tokens': tokens}, allScores: [{'intent': entry.key.name, 'score': score}]));
      }
    }
    if (allIntents.isEmpty) allIntents.add(ClassifiedIntent(type: IntentType.unknown, raw: text, confidence: 0.1));
    allIntents.sort((a,b) => b.confidence.compareTo(a.confidence));
    return allIntents.take(k).toList();
  }
}
