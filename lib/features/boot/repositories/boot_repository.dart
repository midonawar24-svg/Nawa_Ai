/// V14 - Boot Repository

import '../../../engines/memory/memory_engine.dart';
import '../../../engines/knowledge/knowledge_engine.dart';
import '../../../engines/decision/decision_engine.dart';

class BootRepository {
  final List<String> engines = ['Memory Engine', 'Knowledge Engine', 'Decision Engine', 'Voice Engine', 'Search Engine'];

  Future<void> initializeEngines(Function(String) onProgress) async {
    for (final engine in engines) {
      await Future.delayed(const Duration(milliseconds: 400));
      onProgress(engine);
    }
  }
}
