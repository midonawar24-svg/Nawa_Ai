import 'package:flutter/material.dart';
import '../models/message.dart';

/// V13 - Chat Controller - منطق الشات منفصل عن UI
class ChatController extends ChangeNotifier {
  final List<MessageModel> _messages = [];
  bool _isTyping = false;
  String _aiStatus = 'Ready';

  List<MessageModel> get messages => _messages;
  bool get isTyping => _isTyping;
  String get aiStatus => _aiStatus;

  void addMessage(MessageModel message) {
    _messages.add(message);
    notifyListeners();
  }

  void setTyping(bool typing) {
    _isTyping = typing;
    _aiStatus = typing ? 'Thinking' : 'Ready';
    notifyListeners();
  }
}
