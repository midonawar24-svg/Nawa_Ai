import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

/// V12.1 - Glass Components موحدة
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool hasGlow;
  final VoidCallback? onTap;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.hasGlow = false,
    this.onTap,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glassBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: hasGlow ? [BoxShadow(color: (glowColor ?? AppTheme.cyanNeon).withOpacity(0.15), blurRadius: 20)] : null,
      ),
      child: child,
    );
    return onTap != null ? InkWell(onTap: onTap, borderRadius: BorderRadius.circular(borderRadius), child: card) : card;
  }
}

class GlassButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const GlassButton({super.key, required this.label, required this.icon, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.cyanNeon : AppTheme.glassBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isPrimary ? AppTheme.cyanNeon : AppTheme.glassBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: isPrimary ? Colors.black : Colors.white),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isPrimary ? Colors.black : Colors.white)),
        ]),
      ),
    );
  }
}

class ScoreBadge extends StatelessWidget {
  final int score;
  const ScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 90 ? AppTheme.knowledgeEmerald : score >= 80 ? AppTheme.decisionAmber : AppTheme.systemSlate;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Text('$score%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class TransparentResultBar extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final VoidCallback onClose;
  final VoidCallback onGoToChat;

  const TransparentResultBar({super.key, required this.results, required this.onClose, required this.onGoToChat});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xCC0F0F1E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [const Icon(Icons.search, size: 16, color: AppTheme.cyanNeon), const SizedBox(width: 8), const Text('Search Results', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)), const Spacer(), IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 16, color: Colors.white54))]),
          const Divider(color: AppTheme.glassBorder),
          ...results.map((r) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Expanded(child: Text(r['title'], style: const TextStyle(fontSize: 12, color: Colors.white))), ScoreBadge(score: r['score'])]))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onGoToChat, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyanNeon, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Go to Chat', style: TextStyle(color: Colors.black, fontSize: 12)))),
        ]),
      ),
    );
  }
}
