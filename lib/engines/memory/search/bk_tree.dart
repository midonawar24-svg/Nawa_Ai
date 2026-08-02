class BKTreeNode {
  final String word;
  final Map<int, BKTreeNode> children = {};
  BKTreeNode(this.word);
}

class BKTree {
  BKTreeNode? _root;
  final int Function(String a, String b) distanceFunc;
  BKTree(this.distanceFunc);

  void add(String word) {
    if (word.isEmpty) return;
    if (_root == null) { _root = BKTreeNode(word); return; }
    var current = _root!;
    while (true) {
      final dist = distanceFunc(word, current.word);
      if (dist == 0) return;
      final child = current.children[dist];
      if (child == null) { current.children[dist] = BKTreeNode(word); return; }
      current = child;
    }
  }

  List<String> search(String query, int maxDistance) {
    if (_root == null) return [];
    final result = <String>[];
    final stack = [_root!];
    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      final dist = distanceFunc(query, node.word);
      if (dist <= maxDistance) result.add(node.word);
      final minDist = dist - maxDistance;
      final maxDist = dist + maxDistance;
      for (final e in node.children.entries) {
        if (e.key >= minDist && e.key <= maxDist) stack.add(e.value);
      }
    }
    return result;
  }

  void clear() => _root = null;
}
