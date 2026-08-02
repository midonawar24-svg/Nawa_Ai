import 'package:flutter/material.dart';
import 'core/ai_core_os.dart';
import 'core/app.dart';
import 'services/speech_service.dart';

/// V13 - نقطة الدخول - بسيطة جداً - 10/10
/// Flow: Boot -> Chat Home (مش Dashboard)
/// دستور المشروع: AI_CORE_OS_MANIFEST.md
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AICoreOS.initialize();
  await SpeechService.initialize();
  runApp(const AICoreApp());
}
