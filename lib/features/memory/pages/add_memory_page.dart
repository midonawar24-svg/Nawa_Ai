import 'package:flutter/material.dart';
import '../engines/memory/memory_engine.dart';
import '../engines/memory/memory_types.dart';
import '../services/arabic_recognition_service.dart';

class AddMemoryPage extends StatefulWidget {
  const AddMemoryPage({super.key});
  @override State<AddMemoryPage> createState() => _AddMemoryPageState();
}

class _AddMemoryPageState extends State<AddMemoryPage> {
  final _contentController = TextEditingController();
  final _userController = TextEditingController(text: 'user_1');
  final _conversationController = TextEditingController(text: 'conv_1');
  final _tagController = TextEditingController();
  MemoryType _selectedType = MemoryType.episodic;
  double _importance = 0.7;
  List<String> _tags = [];
  Map<String, dynamic>? _analysis;

  void _analyze() {
    if (_contentController.text.trim().isEmpty) return;
    setState(() => _analysis = ArabicRecognitionService.analyzeArabicText(_contentController.text.trim()));
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;
    if (!_tags.contains(trimmed)) setState(() => _tags.add(trimmed));
    _tagController.clear();
  }

  Future<void> _save() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('المحتوى مطلوب')));
      return;
    }

    try {
      await MemoryEngine.remember(
        type: _selectedType,
        content: _contentController.text.trim(),
        tags: _tags,
        userId: _userController.text.trim().isEmpty ? null : _userController.text.trim(),
        conversationId: _conversationController.text.trim().isEmpty ? null : _conversationController.text.trim(),
        importance: _importance,
        metadata: {
          if (_analysis != null) ...{
            'isArabic': _analysis!['isArabic'],
            'dialect': _analysis!['dialect'],
            'isQuestion': _analysis!['isQuestion'],
            'wordCount': _analysis!['wordCount'],
          },
          'createdFrom': 'add_page',
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الذاكرة بنجاح')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _userController.dispose();
    _conversationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة ذاكرة جديدة'), actions: [TextButton(onPressed: _save, child: const Text('حفظ'))]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Content
          Text('المحتوى *', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            maxLines: 5,
            onChanged: (_) => _analyze(),
            textDirection: _contentController.text.isNotEmpty && ArabicRecognitionService.isArabic(_contentController.text) ? TextDirection.rtl : TextDirection.ltr,
            decoration: InputDecoration(
              hintText: 'مثال: محمد نوار من طنطا، تذكر أن طنطا مدينة جميلة...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.edit_note),
            ),
          ),
          if (_analysis != null) ...[
            const SizedBox(height: 8),
            Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.language, size: 16, color: Colors.indigo),
                    const SizedBox(width: 4),
                    const Text('تحليل عربي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const Spacer(),
                    Chip(label: Text(_analysis!['dialect'], style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                  ]),
                  const SizedBox(height: 4),
                  Wrap(spacing: 12, children: [
                    Text('عربي: ${_analysis!['isArabic'] ? 'نعم' : 'لا'}', style: const TextStyle(fontSize: 11)),
                    Text('سؤال: ${_analysis!['isQuestion'] ? 'نعم' : 'لا'}', style: const TextStyle(fontSize: 11)),
                    Text('كلمات: ${_analysis!['wordCount']}', style: const TextStyle(fontSize: 11)),
                    if (_analysis!['hasTypos']) const Text('تم تصحيح إملائي', style: TextStyle(fontSize: 11, color: Colors.orange)),
                  ]),
                  if (_analysis!['corrected'] != _analysis!['original']) ...[
                    const SizedBox(height: 4),
                    Text('مصحح: ${_analysis!['corrected']}', style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
                  ],
                ]),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Type
          Text('نوع الذاكرة', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<MemoryType>(
            selected: {_selectedType},
            onSelectionChanged: (s) => setState(() => _selectedType = s.first),
            segments: MemoryType.values.map((t) => ButtonSegment(value: t, label: Text(t.nameValue), icon: Icon(_getTypeIcon(t)))).toList(),
          ),
          const SizedBox(height: 8),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(_getTypeDescription(_selectedType), style: const TextStyle(fontSize: 12, color: Colors.grey)))),
          const SizedBox(height: 20),

          // Importance Slider
          Text('الأهمية: ${_importance.toStringAsFixed(2)} ${_importance >= 0.9 ? '[CRITICAL - محمية]' : _importance < 0.3 ? '[ستحذف قريباً]' : ''}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          Slider(value: _importance, min: 0.0, max: 1.0, divisions: 20, label: _importance.toStringAsFixed(2), onChanged: (v) => setState(() => _importance = v)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('منخفضة', style: TextStyle(fontSize: 11)), const Text('متوسطة', style: TextStyle(fontSize: 11)), Text('حرجة', style: TextStyle(fontSize: 11, color: _importance >= 0.9 ? Colors.red : Colors.grey))]),
          const SizedBox(height: 20),

          // User & Conversation
          Row(children: [
            Expanded(child: TextField(controller: _userController, decoration: InputDecoration(labelText: 'المستخدم', hintText: 'user_1', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.person)))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _conversationController, decoration: InputDecoration(labelText: 'المحادثة', hintText: 'conv_1', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.chat)))),
          ]),
          const SizedBox(height: 20),

          // Tags
          Text('الوسوم', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _tagController, onSubmitted: _addTag, decoration: InputDecoration(labelText: 'أضف وسم', hintText: 'مهم, طنطا, عمل', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.label)))),
            const SizedBox(width: 8),
            FilledButton(onPressed: () => _addTag(_tagController.text), child: const Text('إضافة')),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 4, children: _tags.map((tag) => Chip(label: Text(tag), onDeleted: () => setState(() => _tags.remove(tag)), deleteIcon: const Icon(Icons.close, size: 16))).toList()),
          const SizedBox(height: 32),

          // Save
          SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('حفظ الذاكرة', style: TextStyle(fontSize: 16)))),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  IconData _getTypeIcon(MemoryType type) {
    switch (type.nameValue) {
      case 'episodic': return Icons.event;
      case 'semantic': return Icons.lightbulb;
      case 'preference': return Icons.favorite;
      case 'skill': return Icons.build;
      default: return Icons.memory;
    }
  }

  String _getTypeDescription(MemoryType type) {
    switch (type.nameValue) {
      case 'episodic': return 'ذاكرة حدثية: أحداث وتجارب محددة (مثلاً: قابلت محمد أمس)';
      case 'semantic': return 'ذاكرة دلالية: حقائق ومعرفة عامة (مثلاً: طنطا مدينة في مصر)';
      case 'preference': return 'ذاكرة تفضيلات: ما يحبه المستخدم (مثلاً: يحب القهوة)';
      case 'skill': return 'ذاكرة مهارة: كيف تفعل شيئاً (مثلاً: طريقة عمل القهوة)';
      default: return '';
    }
  }
}
