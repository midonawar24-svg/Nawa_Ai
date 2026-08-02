/// V12.1 - Voice Engine - placeholder for future
class VoiceEngine {
  static bool _initialized = false;
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }
}
