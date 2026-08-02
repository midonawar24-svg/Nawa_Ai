import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../features/boot/boot_page.dart';

/// V12 - App Entry - نظام ذكي مش Dashboard
class AICoreApp extends StatelessWidget {
  const AICoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI CORE OS V12',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: BootPage(onFinished: () {}),

    );
  }
}
