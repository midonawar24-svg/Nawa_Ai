enum MessageRole { user, assistant }

class MessageModel {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  MessageModel({required this.id, required this.content, required this.role, required this.timestamp});
}
