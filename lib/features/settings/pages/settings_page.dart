import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

/// V13 - Settings Feature - مستقلة
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBlack,
      appBar: AppBar(title: const Text('Settings'), backgroundColor: AppTheme.deepBlack),
      body: const Center(child: Text('Settings - Theme, Language, Backup', style: TextStyle(color: Colors.white))),
    );
  }
}
