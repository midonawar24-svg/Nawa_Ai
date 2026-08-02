import 'package:flutter/material.dart';
import '../engines/memory/memory_engine.dart';
import '../engines/memory/memory_types.dart';
import '../engines/memory/memory_query.dart';
import '../engines/memory/memory_entry.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});
  @override State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  final _searchController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  List<MemorySearchResult> _results = [];
  MemoryType _selectedType = MemoryType.episodic;
  String _selectedTag = '';
  bool _isSearching = false;

  Future<void> _search() async {
    if (_searchController.text.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final results = await MemoryEngine.recall(MemoryQuery(query: _searchController.text.trim(), types: [_selectedType], tags: _selectedTag.isEmpty ? null : [_selectedTag], limit: 50));
    setState(() { _results = results; _isSearching = false; });
  }

  Future<void> _addMemory() async {
    if (_contentController.text.trim().isEmpty) return;
    final tags = _tagController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    await MemoryEngine.remember(type: _selectedType, content: _contentController.text.trim(), tags: tags, userId: 'user_1', importance: 0.7);
    _contentController.clear();
    _tagController.clear();
    if (mounted) Navigator.pop(context);
    _search();
  }

  void _showAddDialog() {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('إضافة ذاكرة جديدة', style: Theme.of(ctx).textTheme.titleLarge),
      const SizedBox(height: 16),
      DropdownButton<MemoryType>(value: _selectedType, isExpanded: true, items: MemoryType.values.map((t) => DropdownMenuItem(value: t, child: Text('${t.nameValue} - priority ${t.priority}'))).toList(), onChanged: (v) => setState(() => _selectedType = v!)),
      TextField(controller: _contentController, maxLines: 3, decoration: const InputDecoration(labelText: 'المحتوى', border: OutlineInputBorder())),
      const SizedBox(height: 8),
      TextField(controller: _tagController, decoration: const InputDecoration(labelText: 'Tags (مفصولة بفاصلة)', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: _addMemory, child: const Text('حفظ'))),
      const SizedBox(height: 16),
    ])));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('🧠 الذاكرة'), DefaultTextStyle(style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey), child: Text('${_results.length} نتيجة - ${_selectedType.nameValue}')))]),,
      floatingActionButton: FloatingActionButton.extended(onPressed: _showAddDialog, icon: const Icon(Icons.add), label: const Text('إضافة')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(children: [
              Expanded(child: TextField(controller: _searchController, onSubmitted: (_) => _search(), decoration: InputDecoration(labelText: 'بحث في الذاكرة', hintText: 'جرب: محمد نوار، مدرسة طنطا', prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), suffixIcon: _isSearching ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _results = []); })))),
              const SizedBox(width: 8),
              FilledButton(onPressed: _search, child: const Text('بحث')),
            ]),
            const SizedBox(height: 8),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: MemoryType.values.map((t) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(t.nameValue), selected: _selectedType == t, onSelected: (_) => setState(() => _selectedType = t)))).toList())),
          ]),
        ),
        Expanded(child: _results.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.psychology_outlined, size: 64, color: Colors.grey[400]), const SizedBox(height: 16), Text('لا توجد نتائج', style: TextStyle(color: Colors.grey[600])), const Text('جرب البحث أو إضافة ذاكرة جديدة', style: TextStyle(color: Colors.grey))])) : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _results.length, itemBuilder: (c, i) {
          final r = _results[i];
          final e = r.entry;
          return Card(margin: const EdgeInsets.only(bottom: 12), child: ExpansionTile(title: Text(e.content, maxLines: 2), bottom: PreferredSize(preferredSize: const Size.fromHeight(20), child: Padding(padding: const EdgeInsets.only(left: 16, bottom: 4), child: Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 4), Wrap(spacing: 4, children: [Chip(label: Text(e.type.nameValue, style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact), if (e.isCritical) const Chip(label: Text('CRITICAL', style: TextStyle(fontSize: 10)), backgroundColor: Colors.redAccent), ...e.tags.take(3).map((tag) => Chip(label: Text(tag, style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact))]), const SizedBox(height: 4), LinearProgressIndicator(value: r.relevance, minHeight: 4), Text('Relevance: ${r.relevance.toStringAsFixed(2)} | Importance: ${e.importance.toStringAsFixed(2)} | FB: ${e.feedbackScore.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.grey))]), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.thumb_up, size: 18), onPressed: () async { await MemoryEngine.provideFeedback(e.id, 1.0); _search(); }), IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () async { await MemoryEngine.forget(e.id); _search(); })]), children: [Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SelectableText('ID: ${e.id}', style: const TextStyle(fontSize: 10, fontFamily: 'monospace')), Text('Created: ${e.createdAt}'), Text('Access: ${e.accessCount}'), Text('Deletion Score: ${e.deletionScore.toStringAsFixed(3)}'), Text('Debug: ${r.debugInfo}'), Text('Metadata: ${e.metadata}')]))]));)))
        })),
      ]),
    );
  }
}
