import '../memory_entry.dart';
import '../memory_types.dart';
abstract class MemoryStore {
  String get name;
  Future<void> save(MemoryEntry entry);
  Future<void> saveAll(List<MemoryEntry> entries);
  Future<List<MemoryEntry>> loadAll();
  Future<List<MemoryEntry>> queryFiltered({List<MemoryType>? types, String? userId, String? conversationId});
  Future<MemoryEntry?> loadById(String id);
  Future<void> delete(String id);
  Future<void> deleteAll(List<String> ids);
  Future<void> clear();
  Future<int> count();
  Future<int> countByType(MemoryType type);
  Future<List<MemoryEntry>> getOldestByType(MemoryType type, int limit);
  Set<String>? searchByTokens(String query);
}
