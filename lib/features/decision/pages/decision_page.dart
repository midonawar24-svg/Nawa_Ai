import 'package:flutter/material.dart';
import '../engines/decision/decision_engine.dart';

class DecisionPage extends StatefulWidget {
  const DecisionPage({super.key});
  @override State<DecisionPage> createState() => _DecisionPageState();
}

class _DecisionPageState extends State<DecisionPage> {
  final _intentController = TextEditingController(text: 'memory');
  List<Decision> _results = [];
  bool _loading = false;

  Future<void> _evaluate() async {
    setState(() => _loading = true);
    final results = await DecisionEngine.instance.evaluate(DecisionContext(intent: _intentController.text.trim(), confidence: 0.8, data: {'query': _intentController.text}));
    setState(() { _results = results; _loading = false; });
  }

  @override Widget build(BuildContext context) {
    final rules = DecisionEngine.instance.ruleNames;
    final stats = DecisionEngine.instance.stats;

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('⚙️ القرارات'), DefaultTextStyle(style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey), child: Text('${rules.length} قواعد')))]),,
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('القواعد الحالية', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(),
          ...rules.map((name) {
            final s = stats[name];
            return ListTile(title: Text(name), bottom: PreferredSize(preferredSize: const Size.fromHeight(20), child: Padding(padding: const EdgeInsets.only(left: 16, bottom: 4), child: Align(alignment: Alignment.centerLeft, child: Text('Exec: ${s?.executions ?? 0} | Fail: ${s?.failures ?? 0} | Avg: ${s?.avgTimeMs.toStringAsFixed(1)}ms'), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () { DecisionEngine.instance.removeRule(name); setState(() {}); }));)))
          }),
          if (rules.isEmpty) const Text('لا توجد قواعد - سيتم إضافة افتراضية عند بدء النظام'),
        ]))),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          TextField(controller: _intentController, decoration: const InputDecoration(labelText: 'Intent للاختبار', hintText: 'memory, knowledge, question', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _evaluate, icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.play_arrow), label: const Text('اختبر القرار'))),
        ]))),
        const SizedBox(height: 16),
        if (_results.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('النتائج (${_results.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(),
          ..._results.map((d) => ListTile(title: Text(d.action), bottom: PreferredSize(preferredSize: const Size.fromHeight(20), child: Padding(padding: const EdgeInsets.only(left: 16, bottom: 4), child: Align(alignment: Alignment.centerLeft, child: Text('Priority: ${d.priority.name} | Confidence: ${d.confidence.toStringAsFixed(2)}'), trailing: Chip(label: Text(d.priority.name))))))),
        ]))),
      ]),
    );
  }
}
