import '../services/logger_service.dart';
import '../engines/memory/memory_engine.dart';
import '../engines/memory/memory_types.dart';
import '../engines/memory/id_generator.dart';
import '../engines/database/database_engine.dart';
import '../engines/decision/decision_engine.dart';
import '../engines/knowledge/knowledge_engine.dart';

class AICoreOS {
  AICoreOS._();
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;
    LoggerService.info('Initializing AI Core OS V6 PRODUCTION READY...');
    try {
      await DatabaseEngine.instance.initialize();
      await MemoryEngine.initialize();
      await KnowledgeEngine.instance.initialize();
      if (!DecisionEngine.instance.hasRules) {
        DecisionEngine.instance.addRule(_defaultMemoryRule());
        DecisionEngine.instance.addRule(_defaultKnowledgeRule());
      }
      _initialized = true;
      LoggerService.info('AI Core OS V6 Ready - 10/10 Production');
    } catch (e, st) {
      LoggerService.error('Failed to initialize', e: e, st: st);
      rethrow;
    }
  }

  static Future<void> shutdown() async {
    if (!_initialized) return;
    await MemoryEngine.decay();
    _initialized = false;
  }

  static Map<String, dynamic> status() {
    return {
      'initialized': _initialized,
      'dbVersion': DatabaseEngine.instance.migrations.currentVersion,
      'dbTables': DatabaseEngine.instance.tableNames,
      'rules': DecisionEngine.instance.ruleCount,
    };
  }

  static Future<Map<String, dynamic>> detailedStatus() async {
    return {
      'initialized': _initialized,
      'dbVersion': DatabaseEngine.instance.migrations.currentVersion,
      'memoryCount': await MemoryEngine.count(),
      'rules': DecisionEngine.instance.ruleCount,
      'knowledgeCount': await KnowledgeEngine.instance.count(),
    };
  }
}

DecisionRule _defaultMemoryRule() {
  return DecisionRule(
    name: 'default_memory_boost',
    priority: DecisionPriority.high,
    condition: (ctx) => ctx.intent == 'memory' || ctx.intent == 'remember',
    action: (ctx) => Decision(id: IdGenerator.generate(MemoryType.episodic), action: 'boost_memory', params: ctx.data, priority: DecisionPriority.high, confidence: 0.8),
  );
}

DecisionRule _defaultKnowledgeRule() {
  return DecisionRule(
    name: 'default_knowledge_search',
    priority: DecisionPriority.medium,
    condition: (ctx) => ctx.intent == 'knowledge' || ctx.intent == 'question',
    action: (ctx) => Decision(id: IdGenerator.generate(MemoryType.semantic), action: 'search_knowledge', params: ctx.data, priority: DecisionPriority.medium, confidence: 0.7),
  );
}
