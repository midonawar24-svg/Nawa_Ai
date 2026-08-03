import '../memory/memory_repository.dart';
class RagEngine {
  final MemoryRepository memoryRepository;
  RagEngine(this.memoryRepository);
  Future<String> buildContext(String query) async {
    final mems = await memoryRepository.recall(query, topK:5);
    if(mems.isEmpty) return '';
    return '[سياق من ذاكرة AI Core OS]\n\{mems.map((m)=>'- \${m.text}').join('\n')}\n[نهاية السياق]';
  }
}
