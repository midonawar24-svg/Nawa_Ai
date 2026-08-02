import '../../services/lock_service.dart';
import '../../services/logger_service.dart';

enum DecisionPriority { low, medium, high, critical }

class DecisionContext {
  final String intent;
  final Map<String, dynamic> data;
  final double confidence;
  DecisionContext({required this.intent, this.data = const {}, this.confidence = 1.0});
}

class Decision {
  final String id;
  final String action;
  final Map<String, dynamic> params;
  final DecisionPriority priority;
  final double confidence;
  Decision({required this.id, required this.action, this.params = const {}, this.priority = DecisionPriority.medium, this.confidence = 1.0});
  Map<String, dynamic> toJson() => {'id': id, 'action': action, 'params': params, 'priority': priority.index, 'confidence': confidence};
  factory Decision.fromJson(Map<String, dynamic> json) => Decision(id: json['id'], action: json['action'], params: json['params'] ?? {}, priority: DecisionPriority.values[json['priority'] ?? 1], confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0);
}

class DecisionRule {
  final String name;
  final DecisionPriority priority;
  final bool Function(DecisionContext ctx) condition;
  final Decision Function(DecisionContext ctx) action;
  DecisionRule({required this.name, required this.condition, required this.action, this.priority = DecisionPriority.medium});
}

class RuleStats {
  int executions = 0;
  int failures = 0;
  int totalTimeMs = 0;
  double get avgTimeMs => executions == 0 ? 0 : totalTimeMs / executions;
  double get failureRate => executions == 0 ? 0 : failures / executions;
}

class DecisionEngine {
  DecisionEngine._();
  static final DecisionEngine instance = DecisionEngine._();
  final List<DecisionRule> _rules = [];
  final Map<String, RuleStats> _stats = {};

  bool get hasRules => _rules.isNotEmpty;
  bool get isEmpty => _rules.isEmpty;
  int get ruleCount => _rules.length;
  bool hasRule(String name) => _rules.any((r) => r.name == name);
  List<String> get ruleNames => _rules.map((r) => r.name).toList();
  Map<String, RuleStats> get stats => Map.unmodifiable(_stats);

  void addRule(DecisionRule rule) {
    if (hasRule(rule.name)) { LoggerService.warn('Rule ${rule.name} already exists'); return; }
    _rules.add(rule);
    _stats[rule.name] = RuleStats();
    _rules.sort((a,b) => b.priority.index.compareTo(a.priority.index));
  }

  bool removeRule(String name) {
    final initial = _rules.length;
    _rules.removeWhere((r) => r.name == name);
    _stats.remove(name);
    return _rules.length < initial;
  }

  void clearRules() { _rules.clear(); _stats.clear(); }

  Future<List<Decision>> evaluate(DecisionContext ctx) async {
    return AppLock.synchronized(() async {
      // FIX: Filter by confidence - ignore low confidence intents
      if (ctx.confidence < 0.1) {
        LoggerService.warn('Low confidence context ${ctx.confidence} - skipping');
        return [];
      }

      final decisions = <Decision>[];
      for (final rule in _rules) {
        final stopwatch = Stopwatch()..start();
        try {
          if (rule.condition(ctx)) {
            final decision = rule.action(ctx);
            // FIX: Combine rule confidence with context confidence
            final combinedConfidence = (decision.confidence * 0.7 + ctx.confidence * 0.3).clamp(0.0, 1.0);
            decisions.add(Decision(id: decision.id, action: decision.action, params: decision.params, priority: decision.priority, confidence: combinedConfidence));
            _stats[rule.name]?.executions++;
          }
        } catch (e, st) {
          _stats[rule.name]?.failures++;
          LoggerService.error('Rule ${rule.name} failed', e: e, st: st);
        } finally {
          stopwatch.stop();
          if (_stats[rule.name] != null) _stats[rule.name]!.totalTimeMs += stopwatch.elapsedMilliseconds;
        }
      }

      // FIX: Sort by priority THEN confidence
      decisions.sort((a,b) {
        final prioCmp = b.priority.index.compareTo(a.priority.index);
        if (prioCmp != 0) return prioCmp;
        return b.confidence.compareTo(a.confidence);
      });

      // FIX: Improved conflict resolution
      if (decisions.isNotEmpty && decisions.first.priority == DecisionPriority.critical) {
        // If multiple critical, keep only highest confidence critical
        final critical = decisions.where((d) => d.priority == DecisionPriority.critical).toList();
        if (critical.length > 1) {
          critical.sort((a,b) => b.confidence.compareTo(a.confidence));
          LoggerService.warn('Multiple critical decisions - keeping highest confidence: ${critical.first.action}');
          return [critical.first];
        }
        return [decisions.first];
      }

      return decisions;
    });
  }
}
