import 'package:flutter/material.dart';

/// V13 - Boot Animation - منفصلة
class BootAnimation {
  static Animation<double> createPulse(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  static Animation<double> createRotation(AnimationController controller) {
    return Tween<double>(begin: 0, end: 1).animate(controller);
  }
}
