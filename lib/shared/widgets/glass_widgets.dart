import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final bool hasGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 24,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppTheme.glassBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
        boxShadow: hasGlow
            ? [
                BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.1), blurRadius: 20, spreadRadius: 0),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }
    return card;
  }
}

class NeonProgressBar extends StatelessWidget {
  final double progress;
  final double width;
  final double height;

  const NeonProgressBar({
    super.key,
    required this.progress,
    this.width = 280,
    this.height = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(height),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: width * progress.clamp(0, 1),
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.cyanNeon, AppTheme.purpleNeon]),
            borderRadius: BorderRadius.circular(height),
            boxShadow: [BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.6), blurRadius: 8)],
          ),
        ),
      ),
    );
  }
}

class ScoreBadge extends StatelessWidget {
  final int score;
  const ScoreBadge({super.key, required this.score});

  Color get color {
    if (score >= 90) return AppTheme.knowledgeEmerald;
    if (score >= 70) return AppTheme.decisionAmber;
    return AppTheme.systemSlate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class TransparentResultBar extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final VoidCallback onClose;
  final VoidCallback? onGoToChat;

  const TransparentResultBar({
    super.key,
    required this.results,
    required this.onClose,
    this.onGoToChat,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 400),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0x990F0F1E), // 60% transparent
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40),
            BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.1), blurRadius: 30),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.cyanNeon.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.search, size: 16, color: AppTheme.cyanNeon),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'نتائج البحث',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.glassBorder),
                // Results
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final r = results[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r['title'],
                                    style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${r['type']} • ${r['time']}',
                                    style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ScoreBadge(score: r['score']),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (onGoToChat != null) ...[
                  const Divider(height: 1, color: AppTheme.glassBorder),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onClose,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('إغلاق', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onGoToChat,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.cyanNeon,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('اذهب للشات →', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
