import '../../services/logger_service.dart';

class Migration {
  final int version;
  final String description;
  final Future<void> Function() up;
  final Future<void> Function()? down;
  Migration({required this.version, required this.description, required this.up, this.down});
}

class MigrationSystem {
  final List<Migration> _migrations = [];
  int _currentVersion = 0;
  void register(Migration migration) {
    if (_migrations.any((m) => m.version == migration.version)) return;
    _migrations.add(migration);
    _migrations.sort((a,b) => a.version.compareTo(b.version));
  }
  int get currentVersion => _currentVersion;
  List<Migration> get pending => _migrations.where((m) => m.version > _currentVersion).toList();
  List<Migration> get all => List.unmodifiable(_migrations);

  Future<void> migrate() async {
    for (final m in pending) {
      LoggerService.info('Migrating to v${m.version}: ${m.description}');
      try {
        await m.up();
        _currentVersion = m.version;
        LoggerService.info('Migration v${m.version} success');
      } catch (e, st) {
        LoggerService.error('Migration v${m.version} failed', e: e, st: st);
        if (m.down != null) {
          try { await m.down!(); } catch (re) { LoggerService.error('Rollback failed: $re'); }
        }
        rethrow;
      }
    }
  }

  Future<void> rollback(int targetVersion) async {
    if (targetVersion >= _currentVersion) return;
    final toRollback = _migrations.where((m) => m.version > targetVersion && m.version <= _currentVersion).toList().reversed;
    for (final m in toRollback) {
      if (m.down != null) { await m.down!(); _currentVersion = m.version - 1; }
    }
    _currentVersion = targetVersion;
  }
}
