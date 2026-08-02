import '../memory/memory_engine.dart';
import '../memory/memory_types.dart';
import '../memory/id_generator.dart';
import '../database/database_engine.dart';
import '../memory/search/arabic_normalizer.dart';
import '../memory/search/text_utils.dart';
import '../../services/lock_service.dart';
import '../../services/logger_service.dart';

class KnowledgeEntry {
  final String id;
  final String content;
  final List<String> tags;
  final double confidence;
  final DateTime createdAt;
  final String contentHash;
  KnowledgeEntry({required this.id, required this.content, this.tags = const [], this.confidence = 0.8, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now(), contentHash = ArabicNormalizer.normalize(content).hashCode.toString();
  Map<String, dynamic> toJson() => {'id': id, 'content': content, 'tags': tags, 'confidence': confidence, 'createdAt': createdAt.toIso8601String(), 'contentHash': contentHash};
  factory KnowledgeEntry.fromJson(Map<String, dynamic> json) => KnowledgeEntry(id: json['id'], content: json['content'], tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [], confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8, createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null);
}

class KnowledgeEngine {
  KnowledgeEngine._();
  static final KnowledgeEngine instance = KnowledgeEngine._();
  final List<KnowledgeEntry> _knowledge = [];
  final Map<String, String> _contentHashIndex = {};
  final Map<String, Set<String>> _tagIndex = {};
  bool _initialized = false;

  void _addToIndex(KnowledgeEntry entry) {
    _contentHashIndex[entry.contentHash] = entry.id;
    for (final tag in entry.tags) {
      final norm = ArabicNormalizer.normalize(tag);
      _tagIndex.putIfAbsent(norm, () => <String>{}).add(entry.id);
    }
  }

  void _removeFromIndex(KnowledgeEntry entry) {
    _contentHashIndex.remove(entry.contentHash);
    for (final tag in entry.tags) {
      final norm = ArabicNormalizer.normalize(tag);
      _tagIndex[norm]?.remove(entry.id);
      if (_tagIndex[norm]?.isEmpty ?? false) _tagIndex.remove(norm);
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final rows = await DatabaseEngine.instance.query('knowledge');
      for (final row in rows) {
        final entry = KnowledgeEntry.fromJson(row);
        _knowledge.add(entry);
        _addToIndex(entry);
      }
    } catch (e) { LoggerService.warn('Failed to load: $e'); }
    _initialized = true;
    LoggerService.info('KnowledgeEngine V7.98 loaded ${_knowledge.length} entries with ${_tagIndex.length} tags');
  }

  Future<void> addKnowledge(String content, {List<String> tags = const [], double confidence = 0.8}) async {
    return AppLock.synchronized(() async {
      // FIX: Input validation
      if (content.trim().isEmpty) throw ArgumentError('Knowledge content cannot be empty');
      if (content.trim().length < 3) throw ArgumentError('Knowledge content too short');
      if (confidence < 0.0 || confidence > 1.0) throw ArgumentError('Confidence must be 0.0-1.0');

      // FIX: Prevent duplicates via content hash
      final normalizedContent = ArabicNormalizer.normalize(content);
      final hash = normalizedContent.hashCode.toString();
      if (_contentHashIndex.containsKey(hash)) {
        final existingId = _contentHashIndex[hash]!;
        LoggerService.warn('Duplicate knowledge detected - existing: $existingId');
        return;
      }

      final id = IdGenerator.generate(MemoryType.semantic);
      final entry = KnowledgeEntry(id: id, content: content, tags: tags, confidence: confidence);
      _knowledge.add(entry);
      _addToIndex(entry);
      await DatabaseEngine.instance.insert('knowledge', entry.toJson());
      await MemoryEngine.remember(type: MemoryType.semantic, content: content, tags: tags, importance: confidence.clamp(0.0, 1.0), metadata: {'source': 'knowledge', 'knowledgeId': id});
      LoggerService.info('Knowledge added: $id - hash: $hash');
    });
  }

  Future<List<KnowledgeEntry>> search(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    final normQuery = ArabicNormalizer.normalize(query);
    final queryTokens = ArabicNormalizer.tokenize(query);
    
    // Fast path: tag index
    final tagMatches = _tagIndex[normQuery];
    List<KnowledgeEntry> candidates;
    if (tagMatches != null && tagMatches.isNotEmpty) {
      candidates = _knowledge.where((k) => tagMatches.contains(k.id)).toList();
    } else {
      candidates = _knowledge;
    }

    final scored = <Map<String, dynamic>>[];
    for (final k in candidates) {
      double score = 0.0;
      final normContent = ArabicNormalizer.normalize(k.content);
      final contentTokens = ArabicNormalizer.tokenize(k.content);
      if (normContent.contains(normQuery)) score += 0.5;
      score += TextUtils.jaccard(queryTokens, contentTokens) * 0.4;
      final normTags = k.tags.map((t) => ArabicNormalizer.normalize(t)).toSet();
      if (queryTokens.any((t) => normTags.contains(t))) score += 0.3;
      score += k.confidence * 0.2;
      if (score > 0.1) scored.add({'entry': k, 'score': score});
    }
    scored.sort((a,b) => (b['score'] as double).compareTo(a['score'] as double));
    return scored.take(limit).map((e) => e['entry'] as KnowledgeEntry).toList();
  }

  Future<bool> removeKnowledge(String id) async {
    return AppLock.synchronized(() async {
      final index = _knowledge.indexWhere((k) => k.id == id);
      if (index == -1) return false;
      final entry = _knowledge.removeAt(index);
      _removeFromIndex(entry);
      await DatabaseEngine.instance.delete('knowledge', id);
      return true;
    });
  }

  Future<int> count() async => _knowledge.length;
  Map<String, dynamic> getStats() => {'total': _knowledge.length, 'uniqueHashes': _contentHashIndex.length, 'tags': _tagIndex.length};
  Future<void> clear() async => AppLock.synchronized(() async { _knowledge.clear(); _contentHashIndex.clear(); _tagIndex.clear(); await DatabaseEngine.instance.clear('knowledge'); });
}
