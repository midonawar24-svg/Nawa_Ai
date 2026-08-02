import '../memory_entry.dart';
import '../memory_types.dart';
import '../search/arabic_normalizer.dart';
import '../search/bk_tree.dart';
import '../search/text_utils.dart';
import 'memory_store.dart';

class InMemoryStore implements MemoryStore {
  final Map<String, MemoryEntry> _storage = {};
  final Map<MemoryType, Set<String>> _byType = {};
  final Map<String, Set<String>> _byUserId = {};
  final Map<String, Set<String>> _byConversation = {};
  final Map<String, Set<String>> _byTag = {};
  final Map<String, Set<String>> _invertedIndex = {};
  final Map<String, int> _tokenRefCount = {};
  final BKTree _bkTree = BKTree((a, b) => TextUtils.levenshtein(a, b, maxDistance: 2));
  final Set<String> _indexedTokens = {};

  InMemoryStore() {
    for (final t in MemoryType.values) _byType[t] = <String>{};
  }

  void _addToIndexes(MemoryEntry e) {
    _byType[e.type]?.add(e.id);
    if (e.userId != null) _byUserId.putIfAbsent(e.userId!, () => <String>{}).add(e.id);
    if (e.conversationId != null) _byConversation.putIfAbsent(e.conversationId!, () => <String>{}).add(e.id);
    for (final tag in e.tags) _byTag.putIfAbsent(ArabicNormalizer.normalize(tag), () => <String>{}).add(e.id);
    for (final token in ArabicNormalizer.tokenize(e.content)) {
      _invertedIndex.putIfAbsent(token, () => <String>{}).add(e.id);
      _tokenRefCount[token] = (_tokenRefCount[token] ?? 0) + 1;
      if (!_indexedTokens.contains(token)) { _bkTree.add(token); _indexedTokens.add(token); }
    }
  }

  void _removeFromIndexes(MemoryEntry e) {
    _byType[e.type]?.remove(e.id);
    if (e.userId != null) {
      _byUserId[e.userId!]?.remove(e.id);
      if (_byUserId[e.userId!]?.isEmpty ?? false) _byUserId.remove(e.userId!);
    }
    if (e.conversationId != null) {
      _byConversation[e.conversationId!]?.remove(e.id);
      if (_byConversation[e.conversationId!]?.isEmpty ?? false) _byConversation.remove(e.conversationId!);
    }
    for (final tag in e.tags) {
      final norm = ArabicNormalizer.normalize(tag);
      _byTag[norm]?.remove(e.id);
      if (_byTag[norm]?.isEmpty ?? false) _byTag.remove(norm);
    }
    for (final token in ArabicNormalizer.tokenize(e.content)) {
      _invertedIndex[token]?.remove(e.id);
      if (_invertedIndex[token]?.isEmpty ?? false) _invertedIndex.remove(token);
      _tokenRefCount[token] = (_tokenRefCount[token] ?? 1) - 1;
      if ((_tokenRefCount[token] ?? 0) <= 0) {
        _tokenRefCount.remove(token);
        _indexedTokens.remove(token);
        // Note: BKTree doesn't support deletion, but we track refCount
        // Periodic rebuild will clean it
      }
    }
  }

  // NEW: Rebuild all indexes from storage - for recovery
  Future<void> rebuildIndexes() async {
    _byType.forEach((k, v) => v.clear());
    _byUserId.clear();
    _byConversation.clear();
    _byTag.clear();
    _invertedIndex.clear();
    _tokenRefCount.clear();
    _indexedTokens.clear();
    _bkTree.clear();
    for (final e in _storage.values) _addToIndexes(e);
  }

  // NEW: Stats for monitoring
  Map<String, dynamic> getStats() {
    return {
      'totalEntries': _storage.length,
      'indexedTokens': _indexedTokens.length,
      'invertedIndexSize': _invertedIndex.length,
      'byType': {for (final t in MemoryType.values) t.nameValue: _byType[t]?.length ?? 0},
      'byUserCount': _byUserId.length,
      'byConversationCount': _byConversation.length,
      'byTagCount': _byTag.length,
      'tokenRefCount': _tokenRefCount.length,
      'bkTreeSize': _indexedTokens.length,
    };
  }

  @override String get name => 'in_memory_v7_98_production';
  
  @override Future<void> save(MemoryEntry entry) async {
    final old = _storage[entry.id];
    if (old != null) _removeFromIndexes(old);
    _storage[entry.id] = entry;
    _addToIndexes(entry);
  }

  // FIX: Batch optimization - rebuild indexes once at end for large batches
  @override Future<void> saveAll(List<MemoryEntry> entries) async {
    if (entries.length > 100) {
      // Fast path for bulk import
      for (final e in entries) {
        final old = _storage[e.id];
        if (old != null) {
          _byType[old.type]?.remove(old.id);
          if (old.userId != null) _byUserId[old.userId!]?.remove(old.id);
          if (old.conversationId != null) _byConversation[old.conversationId!]?.remove(old.id);
        }
        _storage[e.id] = e;
      }
      await rebuildIndexes();
    } else {
      for (final e in entries) {
        final old = _storage[e.id];
        if (old != null) _removeFromIndexes(old);
        _storage[e.id] = e;
        _addToIndexes(e);
      }
    }
  }

  @override Future<List<MemoryEntry>> loadAll() async => _storage.values.toList();
  
  @override Future<List<MemoryEntry>> queryFiltered({List<MemoryType>? types, String? userId, String? conversationId}) async {
    Set<String>? candidateIds;
    if (types != null && types.isNotEmpty) {
      final typeIds = <String>{};
      for (final t in types) typeIds.addAll(_byType[t] ?? {});
      candidateIds = typeIds;
    }
    if (userId != null) {
      final u = _byUserId[userId] ?? {};
      candidateIds = candidateIds == null ? u : candidateIds.intersection(u);
    }
    if (conversationId != null) {
      final c = _byConversation[conversationId] ?? {};
      candidateIds = candidateIds == null ? c : candidateIds.intersection(c);
    }
    if (candidateIds == null) return _storage.values.toList();
    return candidateIds.map((id) => _storage[id]).whereType<MemoryEntry>().toList();
  }

  @override Future<MemoryEntry?> loadById(String id) async => _storage[id];
  @override Future<void> delete(String id) async { final old = _storage.remove(id); if (old != null) _removeFromIndexes(old); }
  @override Future<void> deleteAll(List<String> ids) async { for (final id in ids) { final old = _storage.remove(id); if (old != null) _removeFromIndexes(old); } }
  @override Future<void> clear() async { _storage.clear(); for (final t in MemoryType.values) _byType[t]?.clear(); _byUserId.clear(); _byConversation.clear(); _byTag.clear(); _invertedIndex.clear(); _tokenRefCount.clear(); _bkTree.clear(); _indexedTokens.clear(); }
  @override Future<int> count() async => _storage.length;
  @override Future<int> countByType(MemoryType type) async => _byType[type]?.length ?? 0;
  @override Future<List<MemoryEntry>> getOldestByType(MemoryType type, int limit) async {
    final ids = _byType[type] ?? {};
    final entries = ids.map((id) => _storage[id]).whereType<MemoryEntry>().toList();
    entries.sort((a, b) { if (a.isCritical && !b.isCritical) return 1; if (!a.isCritical && b.isCritical) return -1; final cmp = a.deletionScore.compareTo(b.deletionScore); if (cmp != 0) return cmp; return a.lastAccessedAt.compareTo(b.lastAccessedAt); });
    return entries.take(limit).toList();
  }
  @override Set<String>? searchByTokens(String query) {
    final tokens = ArabicNormalizer.tokenize(query);
    if (tokens.isEmpty) return null;
    final result = <String>{};
    for (final token in tokens) {
      final exact = _invertedIndex[token];
      if (exact != null) result.addAll(exact);
      final fuzzyTokens = _bkTree.search(token, 2);
      for (final ft in fuzzyTokens) { final ids = _invertedIndex[ft]; if (ids != null) result.addAll(ids); }
    }
    return result.isEmpty ? null : result;
  }
}
