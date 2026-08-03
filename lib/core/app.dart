import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../features/boot/boot_page.dart';
import '../features/chat/chat_home.dart'; // ده الملف اللي لقيته

class AICoreApp extends StatefulWidget {
  const AICoreApp({super.key});
  @override
  State<AICoreApp> createState() => _AICoreAppState();
}

class _AICoreAppState extends State<AICoreApp> {
  bool _finishedBoot = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI CORE OS V12',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: _finishedBoot
          ? const ChatMasterPage() // <-- دي الصفحة الرئيسية الحقيقية
          : BootPage(
              onFinished: () {
                setState(() {
                  _finishedBoot = true;
                });
              },
            ),
    );
  }
}
