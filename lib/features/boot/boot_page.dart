import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:nawa_ai/core/app_theme.dart';


/// Boot Page Living - الشاشة السمرا + الكورة الحية بالنور اللي بيروح ويجي
/// المشهد المطلوب: شاشة سودا تمام، الكورة في النص مكتوب عليها AI CORE، النور حواليها حي
class BootPage extends StatefulWidget {
  final VoidCallback onFinished;
  const BootPage({super.key, required this.onFinished});

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late AnimationController _aliveController;

  final List<Map<String, String>> _bootSequence = [
    {'name': 'محرك الذاكرة', 'status': 'OK'},
    {'name': 'محرك المعرفة', 'status': 'OK'},
    {'name': 'محرك القرار', 'status': 'OK'},
  ];

  final List<bool> _completed = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    
    for (var _ in _bootSequence) {
      _completed.add(false);
    }

    // Pulse - نبض الكورة كل 1.5 ثانية
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Rotation - دوران بطيء
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Fade - ظهور انسيابي
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Progress - شريط التقدم
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Alive - حركة النور الحي
    _aliveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _progressController.forward();
      _startBootSequence();
    });
  }

  void _startBootSequence() {
    Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (_currentIndex < _bootSequence.length) {
        setState(() {
          _completed[_currentIndex] = true;
          _currentIndex++;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          _finishBoot();
        });
      }
    });
  }

  void _finishBoot() {
    widget.onFinished();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    _progressController.dispose();
    _aliveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // شاشة سمرا تمام
      body: Stack(
        children: [
          // خلفية سودا نقية - بدون أي عناصر مشتتة
          Container(color: const Color(0xFF000000)),

          // المحتوى الرئيسي
          Center(
            child: FadeTransition(
              opacity: _fadeController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الكورة في النص + النور الحي اللي بيروح ويجي
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow كبير ورا الكورة - نبض حي
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final pulse = _pulseController.value;
                            return Container(
                              width: 260 + pulse * 20,
                              height: 260 + pulse * 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.cyanNeon.withOpacity(0.15 + pulse * 0.15),
                                    blurRadius: 50 + pulse * 30,
                                    spreadRadius: 5 + pulse * 10,
                                  ),
                                  BoxShadow(
                                    color: AppTheme.purpleNeon.withOpacity(0.1 + pulse * 0.1),
                                    blurRadius: 80 + pulse * 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // حلقات بتلف - طاقة بنفسجية
                        RotationTransition(
                          turns: _rotationController,
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.purpleNeon.withOpacity(0.15), width: 1),
                            ),
                          ),
                        ),
                        RotationTransition(
                          turns: ReverseAnimation(_rotationController),
                          child: Container(
                            width: 340,
                            height: 340,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.1), width: 1),
                            ),
                          ),
                        ),

                        // الكورة الرئيسية - AI CORE
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final pulse = 1.0 + _pulseController.value * 0.02;
                            return Transform.scale(
                              scale: pulse,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1E), Color(0xFF000000)],
                                  ),
                                  border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.3), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.4), blurRadius: 30),
                                    BoxShadow(color: AppTheme.purpleNeon.withOpacity(0.3), blurRadius: 50),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // صورة اللوجو
                                    ClipOval(
                                      child: Image.asset(
                                        'assets/images/ai_core_boot_logo.png',
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('AI', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: AppTheme.cyanNeon, blurRadius: 20)])),
                                              const Text('CORE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // النور الحي اللي بيروح ويجي - 12 شعاع
                        ...List.generate(12, (i) {
                          final angle = (i * 30) * math.pi / 180;
                          return AnimatedBuilder(
                            animation: Listenable.merge([_rotationController, _aliveController]),
                            builder: (context, child) {
                              final rot = _rotationController.value * 0.3;
                              final alive = _aliveController.value;
                              final flicker = 0.6 + alive * 0.4 + math.sin(i * 1.2 + alive * 3) * 0.2;
                              final distance = 110 + math.sin(i + alive * 2) * 15;
                              final x = math.cos(angle + rot) * distance;
                              final y = math.sin(angle + rot) * distance;
                              
                              return Transform.translate(
                                offset: Offset(x, y),
                                child: Opacity(
                                  opacity: flicker.clamp(0.3, 1.0),
                                  child: Container(
                                    width: 2 + (i % 3 == 0 ? 2 : 0),
                                    height: 12 + (i % 2 == 0 ? 8 : 0) + alive * 6,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          i % 2 == 0 ? AppTheme.cyanNeon : AppTheme.purpleNeon,
                                          (i % 2 == 0 ? AppTheme.cyanNeon : AppTheme.purpleNeon).withOpacity(0),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (i % 2 == 0 ? AppTheme.cyanNeon : AppTheme.purpleNeon).withOpacity(0.6 * flicker),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),

                        // جسيمات صغيرة حية - بتروح وتيجي
                        ...List.generate(15, (i) {
                          return AnimatedBuilder(
                            animation: Listenable.merge([_rotationController, _aliveController]),
                            builder: (context, child) {
                              final baseAngle = (i * 24) * math.pi / 180;
                              final alive = _aliveController.value;
                              // حركة بيضاوية مش دايرة كاملة - بتروح وتيجي
                              final orbitX = math.cos(baseAngle + alive * 0.5 + i * 0.3) * (90 + math.sin(i) * 30);
                              final orbitY = math.sin(baseAngle + alive * 0.7 + i * 0.2) * (90 + math.cos(i) * 20);
                              final scale = 0.5 + math.sin(alive * 2 + i) * 0.5;
                              
                              return Transform.translate(
                                offset: Offset(orbitX, orbitY),
                                child: Transform.scale(
                                  scale: scale.clamp(0.3, 1.2),
                                  child: Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: i % 3 == 0 ? AppTheme.cyanNeon : i % 3 == 1 ? AppTheme.purpleNeon : Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (i % 3 == 0 ? AppTheme.cyanNeon : AppTheme.purpleNeon).withOpacity(0.8),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),

                        // موجات طاقة بتتمدد وتختفي - تنفس
                        ...List.generate(3, (i) {
                          return AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final progress = (_pulseController.value + i * 0.33) % 1.0;
                              return Opacity(
                                opacity: (1 - progress) * 0.3,
                                child: Container(
                                  width: 180 + progress * 160,
                                  height: 180 + progress * 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: (i % 2 == 0 ? AppTheme.cyanNeon : AppTheme.purpleNeon).withOpacity((1 - progress) * 0.4),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // النصوص تحت - زي ما هي بدون تعديل
                  Column(
                    children: [
                      const Text(
                        'AI CORE OS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'NEURAL OPERATING SYSTEM',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 3,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Progress bar نيون
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Container(
                            width: 180,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 180 * _progressController.value,
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF00D9FF), Color(0xFF7C3AED)]),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.6), blurRadius: 8)],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // قائمة المحركات - بالعربي زي الصورة
                      SizedBox(
                        width: 260,
                        child: Column(
                          children: List.generate(_bootSequence.length, (index) {
                            return AnimatedOpacity(
                              opacity: _completed[index] ? 1 : 0.3,
                              duration: const Duration(milliseconds: 300),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _completed[index] ? AppTheme.knowledgeEmerald.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                                        border: Border.all(
                                          color: _completed[index] ? AppTheme.knowledgeEmerald.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                      child: _completed[index]
                                          ? const Icon(Icons.check, size: 12, color: AppTheme.knowledgeEmerald)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _bootSequence[index]['name']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _completed[index] ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.3),
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                    Text(
                                      _bootSequence[index]['status']!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                        color: _completed[index] ? AppTheme.knowledgeEmerald.withOpacity(0.7) : Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
