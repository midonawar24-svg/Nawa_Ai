/// V13 - Boot Loading Service
class BootLoadingService {
  static Future<void> loadUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<void> loadWorkspace() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<void> loadChats() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
