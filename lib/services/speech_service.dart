import 'package:flutter/foundation.dart';

enum SpeechLanguage { arabicEgyptian, arabicSaudi, arabicGeneral, english }

class SpeechService {
  static bool _isAvailable = false;
  static bool _isListening = false;
  static String _lastWords = '';
  static SpeechLanguage _currentLanguage = SpeechLanguage.arabicEgyptian;

  static bool get isAvailable => _isAvailable;
  static bool get isListening => _isListening;
  static String get lastWords => _lastWords;

  static Future<bool> initialize() async {
    _isAvailable = true;
    debugPrint('SpeechService initialized - Arabic support');
    return true;
  }

  static String getLanguageCode() {
    switch (_currentLanguage) {
      case SpeechLanguage.arabicEgyptian: return 'ar-EG';
      case SpeechLanguage.arabicSaudi: return 'ar-SA';
      case SpeechLanguage.arabicGeneral: return 'ar';
      case SpeechLanguage.english: return 'en-US';
    }
  }

  static Future<String> startListening() async {
    _isListening = true;
    await Future.delayed(const Duration(milliseconds: 500));
    _isListening = false;
    return _lastWords;
  }

  static Future<void> stopListening() async => _isListening = false;
}
