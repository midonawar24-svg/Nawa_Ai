import 'dart:isolate';
import '../../services/lock_service.dart';
import '../../services/logger_service.dart';
import 'memory_constants.dart';
import 'memory_entry.dart';
import 'memory_query.dart';
import 'memory_types.dart';
import 'id_generator.dart';
import 'stores/memory_store.dart';
import 'stores/in_memory_store.dart';
import 'search/arabic_normalizer.dart';
import 'search/text_utils.dart';

List<Map<String, dynamic>> _scoreBatchIsolate(List<dynamic> args) {
  final entriesJson = args[0] as List<Map<String, dynamic>>;
  final queryJson = args[1] as Map<String, dynamic>;
  final query = queryJson['query'] as String;
  final queryTokens = (queryJson['tokens'] as List).cast<String>();
  final results = <Map<String, dynamic>>[];
  for (final e in entriesJson) {
    double score = 0.0;
    if (e['content'].toString().toLowerCase().contains(query.toLowerCase())) score += 0.5;
    final cTokens = (e['tokens'] as List).cast<String>();
    final inter = queryTokens.toSet().intersection(cTokens.toSet()).length;
    final union = queryTokens.toSet().union(cTokens.toSet()).length;
    if (union > 0) score += (inter / union) * 0.4;
    score += (e['importance'] as double) * 0.25;
    if (score > 0.12) results.add({'id': e['id'], 'score': score});
  }
  return results;
}

class MemoryEngine {
  MemoryEngine._();
  static final Map<String, MemoryStore> _stores = {'in_memory': InMemoryStore()};
  static MemoryStore? _activeStore;
  static const int _isolateThreshold = 2000;

  static MemoryStore get activeStore {
    final s = _activeStore ?? _stores['in_memory'];
    if (s == null) throw StateError('No store');
    return s;
  }

  static Future<void> initialize({String storeName = 'in_memory'}) async {
    final store = _stores[storeName];
    if (store == null) throw StateError('Store $storeName not found');
    _activeStore = store;
    LoggerService.info('MemoryEngine V6 PRODUCTION - BKTree + Arabic + Isolate + Feedback');
  }

  static Future<MemoryEntry> remember({required MemoryType type, required String content, Map<String, dynamic> metadata = const {}, String? sessionId, String? userId, String? conversationId, List<String>? tags, double importance = MemoryConstants.importanceDefault}) async {
    return AppLock.synchronized(() async {
      if (content.trim().isEmpty) throw ArgumentError('empty');
      final count = await activeStore.countByType(type);
      if (count >= MemoryConstants.maxMemoriesPerType) {
        final all = await activeStore.queryFiltered(types: [type]);
        all.sort((a, b) { if (a.isCritical && !b.isCritical) return 1; if (!a.isCritical && b.isCritical) return -1; return a.deletionScore.compareTo(b.deletionScore); });
        final toDelete = all.where((e) => !e.isCritical).take(count - MemoryConstants.maxMemoriesPerType + 1).map((e) => e.id).toList();
        if (toDelete.isNotEmpty) await activeStore.deleteAll(toDelete);
      }
      final id = IdGenerator.generate(type);
      final entry = MemoryEntry(id: id, type: type, content: content, metadata: {...metadata, if (tags != null) 'tags': tags}, importance: importance.clamp(0.0, 1.0), sessionId: sessionId, userId: userId, conversationId: conversationId);
      await activeStore.save(entry);
      return entry;
    });
  }

  static Future<List<MemorySearchResult>> recall(MemoryQuery query) async {
    return AppLock.synchronized(() async {
      if (query.query.trim().isEmpty) return [];
      var filtered = await activeStore.queryFiltered(types: query.types.isEmpty ? null : query.types, userId: query.userId, conversationId: query.conversationId);
      if (activeStore is InMemoryStore) {
        final tokenIds = (activeStore as InMemoryStore).searchByTokens(query.query);
        if (tokenIds != null && tokenIds.isNotEmpty && filtered.length > 100) {
          final tf = filtered.where((e) => tokenIds.contains(e.id)).toList();
          if (tf.isNotEmpty) filtered = tf;
        }
      }
      if (query.sessionId != null) filtered = filtered.where((e) => e.sessionId == query.sessionId || e.sessionId == null).toList();
      if (query.tags != null && query.tags!.isNotEmpty) filtered = filtered.where((e) => query.tags!.any((t) => e.tags.contains(t))).toList();
      if (query.minImportance != null) filtered = filtered.where((e) => e.importance >= query.minImportance!).toList();

      if (filtered.length > _isolateThreshold) {
        final entriesJson = filtered.map((e) => {'id': e.id, 'content': e.content, 'tokens': ArabicNormalizer.tokenize(e.content), 'importance': e.importance}).toList();
        final queryJson = {'query': query.query, 'tokens': ArabicNormalizer.tokenize(query.query)};
        try {
          final isoRes = await Isolate.run(() => _scoreBatchIsolate([entriesJson, queryJson]));
          final map = {for (var e in filtered) e.id: e};
          final results = <MemorySearchResult>[];
          for (final r in isoRes) { final en = map[r['id']]; if (en != null) { final sc = _scoreV6(en, query); if (sc.relevance > 0.12) results.add(sc); } }
          results.sort((a, b) => b.relevance.compareTo(a.relevance));
          return results.take(query.limit).toList();
        } catch (_) {}
      }

      final results = <MemorySearchResult>[];
      for (final entry in filtered) {
        if (entry.isExpired) continue;
        final scored = _scoreV6(entry, query);
        if (scored.relevance > MemoryConstants.minRelevance) results.add(scored);
      }
      results.sort((a, b) => b.relevance.compareTo(a.relevance));
      final limited = results.take(query.limit).toList();
      final toUpdate = limited.map((r) => r.entry.copyWith(accessCount: r.entry.accessCount + 1, lastAccessedAt: DateTime.now(), confidence: (r.entry.confidence + MemoryConstants.accessBoost).clamp(0.0, MemoryConstants.maxConfidence))).toList();
      if (toUpdate.isNotEmpty) await activeStore.saveAll(toUpdate);
      return limited;
    });
  }

  static MemorySearchResult _scoreV6(MemoryEntry entry, MemoryQuery query) {
    final lq = ArabicNormalizer.lightNormalize(query.query);
    final lc = ArabicNormalizer.lightNormalize(entry.content);
    final qTokens = ArabicNormalizer.tokenize(query.query);
    final cTokens = ArabicNormalizer.tokenize(entry.content);
    final contentExact = lc.contains(lq) ? MemoryConstants.contentMatchScore : 0.0;
    double tokenScore = qTokens.isEmpty || cTokens.isEmpty ? 0 : TextUtils.jaccard(qTokens, cTokens) * MemoryConstants.tokenMatchScore;
    double fuzzyScore = 0;
    if (tokenScore < 0.3 && qTokens.isNotEmpty) {
      int matches = 0;
      for (final q in qTokens) { for (final c in cTokens) { if (TextUtils.levenshtein(q, c, maxDistance: 2) <= 2) { matches++; break; } } }
      if (matches > 0) fuzzyScore = (matches / qTokens.length) * MemoryConstants.fuzzyMatchScore;
    }
    double tagMatch = 0;
    if (query.tags != null && query.tags!.isNotEmpty) {
      final normTags = entry.tags.map((t) => ArabicNormalizer.normalize(t)).toSet();
      if (query.tags!.any((t) => normTags.contains(ArabicNormalizer.normalize(t)))) tagMatch = MemoryConstants.tagMatchScore;
    }
    final age = DateTime.now().millisecondsSinceEpoch - entry.lastAccessedAt.millisecondsSinceEpoch;
    final recency = (1.0 - (age / MemoryConstants.recencyDivider)).clamp(0.0, MemoryConstants.recencyMax);
    final freq = (entry.accessCount / MemoryConstants.frequencyDivider).clamp(0.0, MemoryConstants.frequencyMax);
    final imp = entry.importance * MemoryConstants.importanceWeight;
    final fb = entry.feedbackScore * MemoryConstants.feedbackWeight;
    double conv = 0; if (query.conversationId != null && entry.conversationId == query.conversationId) conv = MemoryConstants.conversationBoost;
    double ctx = 0; if (query.context != null && query.context!.isNotEmpty) { final ctxT = ArabicNormalizer.tokenize(query.context!); ctx = TextUtils.jaccard(ctxT, cTokens) * MemoryConstants.contextSimilarityWeight; }
    final rel = (contentExact + tokenScore + fuzzyScore + tagMatch + recency + freq + imp + fb + conv + ctx + MemoryConstants.relevanceBase).clamp(0.0, 1.0);
    return MemorySearchResult(entry: entry, relevance: rel, debugInfo: {'exact': contentExact, 'token': tokenScore, 'fuzzy': fuzzyScore, 'imp': imp});
  }

  static Future<void> decay({int batchSize = MemoryConstants.decayBatchSize}) async {
    return AppLock.synchronized(() async {
      final all = await activeStore.loadAll();
      final toDel = <String>[]; final toUp = <MemoryEntry>[];
      for (final e in all) {
        if (e.isCritical) continue;
        final age = DateTime.now().millisecondsSinceEpoch - e.lastAccessedAt.millisecondsSinceEpoch;
        final days = age / 86400000.0;
        final accessF = 1.0 / (1.0 + e.accessCount * 0.15);
        final impF = 1.0 - (e.importance * 0.5);
        final recF = 1.0 + (days * 0.03);
        double dec = MemoryConstants.decayRate * accessF * impF * recF;
        dec = dec.clamp(MemoryConstants.minDecayRate, MemoryConstants.maxDecayRate);
        final upd = e.copyWith(confidence: (e.confidence - dec).clamp(0.0, 1.0));
        if (upd.isExpired) toDel.add(e.id); else toUp.add(upd);
        if (toUp.length >= batchSize) { await activeStore.saveAll(toUp); toUp.clear(); }
        if (toDel.length >= batchSize) { await activeStore.deleteAll(toDel); toDel.clear(); }
      }
      if (toUp.isNotEmpty) await activeStore.saveAll(toUp);
      if (toDel.isNotEmpty) await activeStore.deleteAll(toDel);
    });
  }

  // FIX: These methods exist and are tested
  static Future<void> provideFeedback(String id, double fb) async => AppLock.synchronized(() async { final en = await activeStore.loadById(id); if (en == null) return; final ns = ((en.feedbackScore * 0.7) + (fb.clamp(-1.0, 1.0) * 0.3)).clamp(-1.0, 1.0); await activeStore.save(en.copyWith(feedbackScore: ns)); });
  static Future<void> boostImportance(String id, double boost) async => AppLock.synchronized(() async { final en = await activeStore.loadById(id); if (en == null) return; final ni = (en.importance + boost).clamp(0.0, 1.0); await activeStore.save(en.copyWith(importance: ni)); });
  static Future<void> forget(String id) async => AppLock.synchronized(() => activeStore.delete(id));
  static Future<void> clear() async => AppLock.synchronized(() => activeStore.clear());
  static Future<int> count() async => activeStore.count();
}
