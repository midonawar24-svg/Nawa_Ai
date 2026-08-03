abstract class AiService {
  Stream<String> askStream(String query);
  Future<void> dispose();
}
