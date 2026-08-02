import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';

/// V13 - Control Center - مركز القيادة - مستقل
class ControlCenterPage extends StatelessWidget {
  const ControlCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': '🧠', 'title': 'Memory', 'sub': '128 memories'},
      {'icon': '📚', 'title': 'Knowledge', 'sub': '42 items'},
      {'icon': '⚡', 'title': 'Decision', 'sub': '99.7%'},
      {'icon': '📊', 'title': 'Analytics', 'sub': 'Insights'},
      {'icon': '🕸', 'title': 'Graph', 'sub': 'Neural'},
      {'icon': '⚙', 'title': 'Settings', 'sub': 'Preferences'},
    ];
    
    return Scaffold(
      backgroundColor: AppTheme.deepBlack,
      appBar: AppBar(title: const Text('Control Center'), backgroundColor: AppTheme.deepBlack),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final item = items[i];
          return GlassCard(child: ListTile(leading: Text(item['icon'] as String, style: const TextStyle(fontSize: 20)), title: Text(item['title'] as String, style: const TextStyle(color: Colors.white)), subtitle: Text(item['sub'] as String, style: TextStyle(color: Colors.white.withOpacity(0.5)))));
        },
      ),
    );
  }
}
