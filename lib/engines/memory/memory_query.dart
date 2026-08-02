import 'memory_constants.dart';
import 'memory_entry.dart';
import 'memory_types.dart';

class MemoryQuery {
  final String query;
  final List<MemoryType> types;
  final int limit;
  final String? userId;
  final String? sessionId;
  final String? conversationId;
  final List<String>? tags;
  final double? minImportance;
  final String? context;
  final Map<String, dynamic> metadata;
  const MemoryQuery({required this.query, this.types = const [], this.limit = MemoryConstants.maxQueryResults, this.userId, this.sessionId, this.conversationId, this.tags, this.minImportance, this.context, this.metadata = const {}});
}

class MemorySearchResult {
  final MemoryEntry entry;
  final double relevance;
  final Map<String, dynamic> debugInfo;
  const MemorySearchResult({required this.entry, required this.relevance, this.debugInfo = const {}});
}
