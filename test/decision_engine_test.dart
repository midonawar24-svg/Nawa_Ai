import 'package:flutter_test/flutter_test.dart';
import 'package:ai_smart_phone/engines/decision/decision_engine.dart';

void main() {
  setUp(() { DecisionEngine.instance.clearRules(); });

  test('Add and hasRule', () {
    final rule = DecisionRule(name: 'test_rule', condition: (ctx) => true, action: (ctx) => Decision(id: '1', action: 'test'));
    DecisionEngine.instance.addRule(rule);
    expect(DecisionEngine.instance.hasRule('test_rule'), true);
    expect(DecisionEngine.instance.ruleCount, 1);
  });

  test('Prevent duplicate', () {
    final rule = DecisionRule(name: 'dup', condition: (ctx) => true, action: (ctx) => Decision(id: '1', action: 'test'));
    DecisionEngine.instance.addRule(rule);
    DecisionEngine.instance.addRule(rule);
    expect(DecisionEngine.instance.ruleCount, 1);
  });

  test('Remove rule', () {
    final rule = DecisionRule(name: 'to_remove', condition: (ctx) => true, action: (ctx) => Decision(id: '1', action: 'test'));
    DecisionEngine.instance.addRule(rule);
    expect(DecisionEngine.instance.removeRule('to_remove'), true);
    expect(DecisionEngine.instance.hasRule('to_remove'), false);
  });

  test('Priority sorting', () async {
    DecisionEngine.instance.addRule(DecisionRule(name: 'low', priority: DecisionPriority.low, condition: (ctx) => true, action: (ctx) => Decision(id: '1', action: 'low', priority: DecisionPriority.low)));
    DecisionEngine.instance.addRule(DecisionRule(name: 'high', priority: DecisionPriority.high, condition: (ctx) => true, action: (ctx) => Decision(id: '2', action: 'high', priority: DecisionPriority.high)));
    final results = await DecisionEngine.instance.evaluate(DecisionContext(intent: 'test'));
    expect(results.first.action, 'high');
  });

  test('Confidence filtering', () async {
    DecisionEngine.instance.addRule(DecisionRule(name: 'test', condition: (ctx) => true, action: (ctx) => Decision(id: '1', action: 'test')));
    final lowConf = await DecisionEngine.instance.evaluate(DecisionContext(intent: 'test', confidence: 0.05));
    expect(lowConf.isEmpty, true);
  });

  test('Critical conflict resolution', () async {
    DecisionEngine.instance.addRule(DecisionRule(name: 'crit1', priority: DecisionPriority.critical, condition: (ctx) => true, action: (ctx) => Decision(id: '1', action: 'crit1', priority: DecisionPriority.critical, confidence: 0.9)));
    DecisionEngine.instance.addRule(DecisionRule(name: 'crit2', priority: DecisionPriority.critical, condition: (ctx) => true, action: (ctx) => Decision(id: '2', action: 'crit2', priority: DecisionPriority.critical, confidence: 0.5)));
    final results = await DecisionEngine.instance.evaluate(DecisionContext(intent: 'test'));
    expect(results.length, 1);
    expect(results.first.confidence, 0.9);
  });

  test('Error isolation', () async {
    DecisionEngine.instance.addRule(DecisionRule(name: 'fail', condition: (ctx) => throw Exception('fail'), action: (ctx) => Decision(id: '1', action: 'fail')));
    DecisionEngine.instance.addRule(DecisionRule(name: 'ok', condition: (ctx) => true, action: (ctx) => Decision(id: '2', action: 'ok')));
    final results = await DecisionEngine.instance.evaluate(DecisionContext(intent: 'test'));
    expect(results.length, 1);
    expect(results.first.action, 'ok');
  });
}
