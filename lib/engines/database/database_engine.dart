import '../../services/lock_service.dart';
import '../../services/logger_service.dart';
import '../memory/id_generator.dart';
import '../memory/memory_types.dart';
import 'migration_system.dart';

class DatabaseEngine {
  DatabaseEngine._();
  static final DatabaseEngine instance = DatabaseEngine._();
  final Map<String, List<Map<String, dynamic>>> _tables = {};
  final MigrationSystem migrations = MigrationSystem();
  bool _initialized = false;
  final Set<String> _allowedTables = {'memories', 'knowledge', 'decisions', 'intents'};
  bool _strictTableValidation = false;

  List<String> get tableNames => _tables.keys.toList();
  bool get isInitialized => _initialized;
  void enableStrictTableValidation() => _strictTableValidation = true;

  Future<void> initialize() async {
    return AppLock.synchronized(() async {
      if (_initialized) return;
      migrations.register(Migration(version: 1, description: 'Create core tables', up: () async {
        _tables['memories'] = []; _tables['knowledge'] = []; _tables['decisions'] = []; _tables['intents'] = [];
      }, down: () async { _tables.clear(); }));
      migrations.register(Migration(version: 2, description: 'Add indexes', up: () async {}));
      await migrations.migrate();
      _initialized = true;
      LoggerService.info('DatabaseEngine V7.98 initialized v${migrations.currentVersion}');
    });
  }

  void _validateTable(String table) {
    if (_strictTableValidation && !_allowedTables.contains(table) && !_tables.containsKey(table)) {
      LoggerService.warn('Unknown table $table - allowed: $_allowedTables. Enable strict mode may be hiding typo');
    }
  }

  Future<String> insert(String table, Map<String, dynamic> data) async {
    return AppLock.synchronized(() async {
      _validateTable(table);
      final list = _tables.putIfAbsent(table, () => []);
      final id = data['id'] as String? ?? IdGenerator.generate(MemoryType.semantic);
      // FIX: Preserve createdAt if exists (for import)
      final row = {...data, 'id': id, 'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String()};
      list.add(row);
      return id;
    });
  }

  // FIX: Protect query with lock for consistency
  Future<List<Map<String, dynamic>>> query(String table, {Map<String, dynamic>? where, int? limit}) async {
    return AppLock.synchronized(() async {
      _validateTable(table);
      var list = _tables[table] ?? [];
      if (where != null && where.isNotEmpty) {
        list = list.where((row) { for (final k in where.keys) { if (row[k] != where[k]) return false; } return true; }).toList();
      }
      if (limit != null && list.length > limit) list = list.take(limit).toList();
      return List.from(list);
    });
  }

  // FIX: Protect queryById with lock
  Future<Map<String, dynamic>?> queryById(String table, String id) async {
    return AppLock.synchronized(() async {
      _validateTable(table);
      final list = _tables[table] ?? [];
      try { return list.firstWhere((row) => row['id'] == id); } catch (_) { return null; }
    });
  }

  Future<bool> update(String table, String id, Map<String, dynamic> data) async {
    return AppLock.synchronized(() async {
      _validateTable(table);
      final list = _tables[table]; if (list == null) return false;
      final index = list.indexWhere((row) => row['id'] == id); if (index == -1) return false;
      list[index] = {...list[index], ...data, 'updatedAt': DateTime.now().toIso8601String()};
      return true;
    });
  }

  Future<bool> delete(String table, String id) async {
    return AppLock.synchronized(() async {
      _validateTable(table);
      final list = _tables[table]; if (list == null) return false;
      final initial = list.length; list.removeWhere((row) => row['id'] == id); return list.length < initial;
    });
  }

  Future<int> count(String table) async => AppLock.synchronized(() async => _tables[table]?.length ?? 0);
  Future<void> clear(String table) async => AppLock.synchronized(() async { _validateTable(table); _tables[table]?.clear(); });
  Future<void> clearAll() async => AppLock.synchronized(() async => _tables.forEach((k, v) => v.clear()));
}
