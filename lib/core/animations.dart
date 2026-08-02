import 'package:flutter/material.dart';

/// V12 - Animations - كل الحركات موحدة
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration boot = Duration(seconds: 3);

  static Widget fadeTransition(Animation<double> animation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }

  static Widget slideTransition(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(animation),
      child: child,
    );
  }

  static Widget scaleFadeTransition(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
