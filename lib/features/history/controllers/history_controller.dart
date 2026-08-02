import 'package:flutter/material.dart';

/// V13 - History Controller
class HistoryController extends ChangeNotifier {
  List<String> _conversations = [];
  List<String> get conversations => _conversations;
}
