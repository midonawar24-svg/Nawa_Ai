import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warn, error, none }

class LoggerService {
  static LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static void setLevel(LogLevel level) {
    _currentLevel = level;
    dev.log('Log level set to $level', name: 'AI_CORE');
  }
  static bool _shouldLog(LogLevel level) => level.index >= _currentLevel.index;
  static void debug(String msg, {String tag = 'AI_CORE'}) {
    if (!_shouldLog(LogLevel.debug)) return;
    dev.log(msg, name: tag);
  }
  static void info(String msg, {String tag = 'AI_CORE'}) {
    if (!_shouldLog(LogLevel.info)) return;
    dev.log(msg, name: tag);
  }
  static void warn(String msg, {String tag = 'AI_CORE'}) {
    if (!_shouldLog(LogLevel.warn)) return;
    dev.log('WARN: $msg', name: tag);
  }
  static void error(String msg, {String tag = 'AI_CORE', Object? e, StackTrace? st}) {
    if (!_shouldLog(LogLevel.error)) return;
    dev.log('ERROR: $msg ${e ?? ''}', name: tag, error: e, stackTrace: st, level: 1000);
  }
}
