import 'package:synchronized/synchronized.dart';

class AppLock {
  static final Lock _lock = Lock();
  static Future<T> synchronized<T>(Future<T> Function() func) => _lock.synchronized(func);
}
