import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';

/// V13 - History Feature - مستقلة
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBlack,
      appBar: AppBar(title: const Text('History'), backgroundColor: AppTheme.deepBlack),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(child: Text('No conversations yet - Start your first chat', style: TextStyle(color: Colors.white.withOpacity(0.6)))),
        ],
      ),
    );
  }
}
