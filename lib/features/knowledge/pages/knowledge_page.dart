import 'package:flutter/material.dart';
import '../engines/knowledge/knowledge_engine.dart';

class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});
  @override State<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {
  final _searchController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  List<KnowledgeEntry> _results = [];
  bool _loading = false;

  Future<void> _search() async {
    if (_searchController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final results = await KnowledgeEngine.instance.search(_searchController.text.trim(), limit: 30);
    setState(() { _results = results; _loading = false; });
  }

  Future<void> _addKnowledge() async {
    if (_contentController.text.trim().isEmpty) return;
    final tags = _tagController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    try {
      await KnowledgeEngine.instance.addKnowledge(_contentController.text.trim(), tags: tags);
      _contentController.clear(); _tagController.clear();
      if (mounted) Navigator.pop(context);
      _search();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('📚 المعرفة'), DefaultTextStyle(style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey), child: Text('${_results.length} نتيجة')))]),,
      floatingActionButton: FloatingActionButton.extended(onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('إضافة معرفة', style: Theme.of(ctx).textTheme.titleLarge), const SizedBox(height: 16), TextField(controller: _contentController, maxLines: 3, decoration: const InputDecoration(labelText: 'المحتوى', border: OutlineInputBorder())), const SizedBox(height: 8), TextField(controller: _tagController, decoration: const InputDecoration(labelText: 'Tags', border: OutlineInputBorder())), const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton(onPressed: _addKnowledge, child: const Text('حفظ'))), const SizedBox(height: 16)]))), icon: const Icon(Icons.add), label: const Text('إضافة')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: TextField(controller: _searchController, onSubmitted: (_) => _search(), decoration: InputDecoration(labelText: 'بحث في المعرفة', prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), suffixIcon: _loading ? const CircularProgressIndicator() : null))), const SizedBox(width: 8), FilledButton(onPressed: _search, child: const Text('بحث'))])),
        Expanded(child: _results.isEmpty ? const Center(child: Text('لا توجد نتائج')) : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _results.length, itemBuilder: (c, i) {
          final k = _results[i];
          return Card(child: ListTile(title: Text(k.content), bottom: PreferredSize(preferredSize: const Size.fromHeight(20), child: Padding(padding: const EdgeInsets.only(left: 16, bottom: 4), child: Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Wrap(spacing: 4, children: k.tags.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 10)))).toList()), Text('Confidence: ${k.confidence.toStringAsFixed(2)} | ${k.createdAt.toString().substring(0, 16)}', style: const TextStyle(fontSize: 11))]), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async { await KnowledgeEngine.instance.removeKnowledge(k.id); _search(); })));)))
        })),
      ]),
    );
  }
}
