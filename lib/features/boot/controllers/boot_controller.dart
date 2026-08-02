import 'package:flutter/material.dart';

/// V13 - Boot Controller - منطق الإقلاع منفصل
class BootController extends ChangeNotifier {
  bool _isInitialized = false;
  double _progress = 0.0;
  List<String> _completedEngines = [];
  
  bool get isInitialized => _isInitialized;
  double get progress => _progress;
  List<String> get completedEngines => _completedEngines;

  final List<String> engines = [
    'Memory Engine',
    'Knowledge Engine', 
    'Decision Engine',
    'Voice Engine',
    'Search Engine',
  ];

  Future<void> initialize() async {
    for (int i = 0; i < engines.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      _completedEngines.add(engines[i]);
      _progress = (i + 1) / engines.length;
      notifyListeners();
    }
    _isInitialized = true;
    notifyListeners();
  }
}
