abstract class ConversationRepository {
  Future<void> addMessage(String role, String text);
  Future<List<Map<String,String>>> getRecentHistory({int limit=10});
}
