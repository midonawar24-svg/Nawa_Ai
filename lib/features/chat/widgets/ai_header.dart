import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';

/// V12.1 - AI Header - بسيط جداً
/// ☰  AI CORE  🟢 Ready  AR
class AIHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onControlCenterTap;
  final VoidCallback onLanguageToggle;
  final bool isArabic;
  final String aiStatus;
  final AnimationController langController;
  final bool showLangHint;

  const AIHeader({
    super.key,
    required this.onMenuTap,
    required this.onControlCenterTap,
    required this.onLanguageToggle,
    required this.isArabic,
    required this.aiStatus,
    required this.langController,
    required this.showLangHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(color: AppTheme.deepBlack.withOpacity(0.9), border: Border(bottom: BorderSide(color: AppTheme.glassBorder.withOpacity(0.5)))),
      child: Row(
        children: [
          IconButton(onPressed: onMenuTap, icon: const Icon(Icons.menu, size: 20, color: Colors.white), style: IconButton.styleFrom(backgroundColor: AppTheme.glassBg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(width: 12),
          Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.3), blurRadius: 12)]), child: ClipOval(child: Image.asset('assets/images/ai_core_boot_logo.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.cyanNeon, AppTheme.purpleNeon]), shape: BoxShape.circle), child: const Center(child: Text('AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))))))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AI CORE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
            Row(children: [Icon(_getStatusIcon(), size: 6, color: _getStatusColor()), const SizedBox(width: 4), Text(aiStatus, style: TextStyle(fontSize: 10, color: _getStatusColor()))]),
          ]),
          const Spacer(),
          Stack(children: [
            FadeTransition(opacity: langController, child: ScaleTransition(scale: langController, child: GlassCard(borderRadius: 12, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), onTap: onLanguageToggle, hasGlow: true, child: Row(mainAxisSize: MainAxisSize.min, children: [Text(isArabic ? 'AR' : 'EN', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.cyanNeon)), const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('|', style: TextStyle(fontSize: 10, color: Colors.white24))), Text(isArabic ? 'EN' : 'AR', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)))])))),
            if (showLangHint) Positioned(top: 36, right: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.deepBlack3, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.glassBorder)), child: Text(isArabic ? 'دوس للتبديل' : 'Tap to switch', style: const TextStyle(fontSize: 9, color: Colors.white70)))),
          ]),
          const SizedBox(width: 8),
          IconButton(onPressed: onControlCenterTap, icon: const Icon(Icons.dashboard_outlined, size: 18, color: Colors.white70), style: IconButton.styleFrom(backgroundColor: AppTheme.glassBg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (aiStatus) {
      case 'Thinking': return AppTheme.purpleNeon;
      case 'Listening': return AppTheme.searchCyan;
      case 'Typing': return AppTheme.decisionAmber;
      default: return AppTheme.knowledgeEmerald;
    }
  }

  IconData _getStatusIcon() {
    return Icons.circle;
  }
}
