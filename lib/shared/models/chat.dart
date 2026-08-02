class ChatModel {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isArchived;
  final int messageCount;

  ChatModel({required this.id, required this.title, required this.lastMessage, required this.updatedAt, this.isPinned = false, this.isArchived = false, this.messageCount = 0});
}
