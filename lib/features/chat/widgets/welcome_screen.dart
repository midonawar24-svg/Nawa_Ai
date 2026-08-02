import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';

/// V12.1 - Welcome Screen - قبل أول رسالة
class WelcomeScreen extends StatelessWidget {
  final bool isArabic;
  final Function(String) onSuggestionTap;

  const WelcomeScreen({super.key, required this.isArabic, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [AppTheme.cyanNeon, AppTheme.purpleNeon]), boxShadow: [BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.3), blurRadius: 20)]), child: const Icon(Icons.smart_toy, size: 40, color: Colors.white)),
            const SizedBox(height: 20),
            Text('AI CORE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(isArabic ? 'كيف يمكنني مساعدتك اليوم؟' : 'How can I help you today?', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: GlassCard(hasGlow: true, onTap: () => onSuggestionTap(isArabic ? 'ابدأ محادثة جديدة' : 'Start new chat'), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add, size: 16, color: AppTheme.cyanNeon), const SizedBox(width: 8), Text(isArabic ? 'ابدأ محادثة جديدة' : 'Start New Chat', style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold))]))),
            const SizedBox(height: 24),
            Align(alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft, child: Text(isArabic ? 'اقتراحات:' : 'Suggested:', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)))),
            const SizedBox(height: 12),
            ...[
              isArabic ? '💡 اشرح لي Flutter' : '💡 Explain Flutter',
              isArabic ? '🧠 تذكر هذا' : '🧠 Remember this',
              isArabic ? '📚 لخص الملف' : '📚 Summarize file',
              isArabic ? '⚡ ساعدني في البرمجة' : '⚡ Help me code',
            ].map((s) => GlassCard(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), onTap: () => onSuggestionTap(s), child: Text(s, style: const TextStyle(fontSize: 12, color: Colors.white70)))),
          ],
        ),
      ),
    );
  }
}
