import 'package:flutter/material.dart';
import '../engines/memory/memory_entry.dart';
import '../engines/memory/memory_query.dart';
import '../engines/memory/memory_engine.dart';
import '../services/arabic_recognition_service.dart';

class MemoryDetailPage extends StatefulWidget {
  final MemorySearchResult result;
  const MemoryDetailPage({super.key, required this.result});

  @override State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage> {
  late MemoryEntry _entry;
  late MemorySearchResult _result;

  @override void initState() {
    super.initState();
    _entry = widget.result.entry;
    _result = widget.result;
  }

  Future<void> _provideFeedback(double score) async {
    await MemoryEngine.provideFeedback(_entry.id, score);
    final updated = await MemoryEngine.activeStore.loadById(_entry.id);
    if (updated != null && mounted) {
      setState(() => _entry = updated);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(score > 0 ? 'شكراً! تم رفع التقييم' : 'تم خفض التقييم')));
    }
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = _entry.metadata['isArabic'] == true || ArabicRecognitionService.isArabic(_entry.content);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الذاكرة'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete), onPressed: () async {
            final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('حذف الذاكرة'), content: const Text('هل أنت متأكد؟'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف'))]));
            if (confirm == true) {
              await MemoryEngine.forget(_entry.id);
              if (mounted) Navigator.pop(context, true);
            }
          }),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Relevance Explanation Card - الميزة اللي طلبتها
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.analytics, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('لماذا ظهرت هذه النتيجة؟', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Chip(label: Text('${(_result.relevance * 100).toStringAsFixed(0)}% تطابق', style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: theme.colorScheme.primary, labelStyle: TextStyle(color: theme.colorScheme.onPrimary)),
                ]),
                const Divider(height: 20),
                _ReasonRow(icon: Icons.text_fields, label: 'تطابق المحتوى', value: _result.debugInfo['exact'] ?? 0.0, isMatch: (_result.debugInfo['exact'] ?? 0) > 0.1),
                _ReasonRow(icon: Icons.tag, label: 'تطابق الوسوم', value: 0.3, isMatch: _entry.tags.isNotEmpty),
                _ReasonRow(icon: Icons.spellcheck, label: 'تشابه إملائي (BK-Tree + Levenshtein)', value: _result.debugInfo['fuzzy'] ?? 0.0, isMatch: (_result.debugInfo['fuzzy'] ?? 0) > 0.05),
                _ReasonRow(icon: Icons.token, label: 'تطابق الكلمات (Jaccard)', value: _result.debugInfo['token'] ?? 0.0, isMatch: (_result.debugInfo['token'] ?? 0) > 0.1),
                _ReasonRow(icon: Icons.star, label: 'الأهمية', value: _result.debugInfo['imp'] ?? 0.0, isMatch: _entry.importance > 0.6),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _result.relevance, minHeight: 6, borderRadius: BorderRadius.circular(3)),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Content Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Chip(label: Text(_entry.type.nameValue), avatar: Icon(_getTypeIcon(_entry.type), size: 16)),
                  const SizedBox(width: 8),
                  if (_entry.isCritical) const Chip(label: Text('CRITICAL'), backgroundColor: Colors.red, labelStyle: TextStyle(color: Colors.white, fontSize: 10)),
                  if (isArabic) const Chip(label: Text('عربي'), backgroundColor: Colors.indigo, labelStyle: TextStyle(color: Colors.white, fontSize: 10)),
                  const Spacer(),
                  Icon(_getStatusIcon(_entry), size: 20, color: Colors.grey),
                ]),
                const SizedBox(height: 12),
                SelectableText(_entry.content, style: theme.textTheme.bodyLarge?.copyWith(height: 1.6), textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr),
                const SizedBox(height: 16),
                Wrap(spacing: 8, runSpacing: 4, children: _entry.tags.map((tag) => Chip(label: Text(tag), avatar: const Icon(Icons.label, size: 14))).toList()),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _StatItem(icon: Icons.star, label: 'الأهمية', value: _entry.importance.toStringAsFixed(2), progress: _entry.importance, color: Colors.orange),
              _StatItem(icon: Icons.thumb_up, label: 'التقييم', value: _entry.feedbackScore.toStringAsFixed(2), progress: (_entry.feedbackScore + 1) / 2, color: Colors.green),
              _StatItem(icon: Icons.visibility, label: 'مرات الوصول', value: '${_entry.accessCount}', progress: (_entry.accessCount / 20).clamp(0.0, 1.0), color: Colors.blue),
              _StatItem(icon: Icons.security, label: 'الثقة', value: _entry.confidence.toStringAsFixed(2), progress: _entry.confidence, color: Colors.purple),
            ],
          ),
          const SizedBox(height: 16),

          // Dates
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _DateRow(icon: Icons.calendar_today, label: 'تاريخ الإنشاء', date: _entry.createdAt),
                const Divider(),
                _DateRow(icon: Icons.access_time, label: 'آخر استخدام', date: _entry.lastAccessedAt),
                const Divider(),
                _DateRow(icon: Icons.delete, label: 'درجة الحذف', date: null, customValue: '${_entry.deletionScore.toStringAsFixed(3)} - ${ _entry.isCritical ? 'محمية [CRITICAL]' : _entry.deletionScore < 0.3 ? 'ستحذف قريباً' : 'آمنة'}'),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Metadata
          if (_entry.metadata.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('بيانات إضافية', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._entry.metadata.entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [Text('${e.key}: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Expanded(child: Text('${e.value}', style: const TextStyle(fontSize: 12)))]))),
                ]),
              ),
            ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(children: [
            Expanded(child: FilledButton.icon(onPressed: () => _provideFeedback(1.0), icon: const Icon(Icons.thumb_up), label: const Text('مفيد'))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(onPressed: () => _provideFeedback(-1.0), icon: const Icon(Icons.thumb_down), label: const Text('غير مفيد'))),
          ]),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('تعديل'))),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  IconData _getTypeIcon(type) {
    switch (type.nameValue) {
      case 'episodic': return Icons.event;
      case 'semantic': return Icons.lightbulb;
      case 'preference': return Icons.favorite;
      case 'skill': return Icons.build;
      default: return Icons.memory;
    }
  }

  IconData _getStatusIcon(MemoryEntry e) {
    if (e.isCritical) return Icons.shield;
    if (e.confidence < 0.3) return Icons.warning;
    return Icons.check_circle;
  }
}

class _ReasonRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final bool isMatch;
  const _ReasonRow({required this.icon, required this.label, required this.value, required this.isMatch});
  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 16, color: isMatch ? Colors.green : Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: isMatch ? Colors.black87 : Colors.grey))),
        Text('${(value * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isMatch ? Colors.green : Colors.grey)),
        const SizedBox(width: 8),
        Icon(isMatch ? Icons.check_circle : Icons.cancel, size: 16, color: isMatch ? Colors.green : Colors.grey),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final Color color;
  const _StatItem({required this.icon, required this.label, required this.value, required this.progress, required this.color});
  @override Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600))]),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      LinearProgressIndicator(value: progress, minHeight: 4, color: color, backgroundColor: color.withOpacity(0.2)),
    ])));
  }
}

class _DateRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? date;
  final String? customValue;
  const _DateRow({required this.icon, required this.label, this.date, this.customValue});
  @override Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const Spacer(),
      Text(customValue ?? (date != null ? '${date!.day}/${date!.month} ${date!.hour}:${date!.minute.toString().padLeft(2, '0')}' : ''), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }
}
