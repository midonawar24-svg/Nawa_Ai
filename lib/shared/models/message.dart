enum MessageRole { user, assistant, system }

class MessageModel {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isWelcome;

  MessageModel({required this.id, required this.content, required this.role, required this.timestamp, this.isWelcome = false});
}
