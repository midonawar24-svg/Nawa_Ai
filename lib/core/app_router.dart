import 'package:flutter/material.dart';
import '../features/boot/pages/boot_page.dart';
import '../features/chat/pages/chat_home_page.dart';
import '../features/memory/pages/memory_page.dart';
import '../features/knowledge/pages/knowledge_page.dart';
import '../features/history/pages/history_page.dart';
import '../features/settings/pages/settings_page.dart';

/// V13 - Router - 10/10 - كل التنقل من هنا - لا ملفات قديمة
class AppRouter {
  static const String boot = '/';
  static const String chatHome = '/chat';
  static const String memory = '/memory';
  static const String knowledge = '/knowledge';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String decision = '/decision';
  static const String analytics = '/analytics';
  static const String graph = '/graph';
  static const String about = '/about';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case boot:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => const BootPage(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        );
      case chatHome:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ChatHomePage(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        );
      case memory:
        return MaterialPageRoute(builder: (_) => const MemoryPage());
      case knowledge:
        return MaterialPageRoute(builder: (_) => const KnowledgePage());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryPage());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(builder: (_) => const ChatHomePage());
    }
  }
}
