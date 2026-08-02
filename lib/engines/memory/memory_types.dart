import 'memory_constants.dart';
enum MemoryType { episodic, semantic, preference, skill }
extension MemoryTypeX on MemoryType {
  String get nameValue => toString().split('.').last;
  int get priority {
    switch (this) {
      case MemoryType.episodic: return MemoryConstants.episodicPriority;
      case MemoryType.semantic: return MemoryConstants.semanticPriority;
      case MemoryType.preference: return MemoryConstants.preferencePriority;
      case MemoryType.skill: return MemoryConstants.skillPriority;
    }
  }
}
