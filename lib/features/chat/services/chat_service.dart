/// V13 - Chat Service - منطق إرسال واستقبال
class ChatService {
  static Future<String> sendMessage(String text) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (text.contains('طنطا')) {
      return 'طنطا عاصمة الغربية، مشهورة بمسجد السيد البدوي.';
    }
    return 'فهمت: "\$text" - أنا AI CORE OS';
  }
}
