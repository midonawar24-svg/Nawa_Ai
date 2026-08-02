import 'memory_constants.dart';
import 'memory_types.dart';

class MemoryEntry {
  final String id;
  final MemoryType type;
  final String content;
  final Map<String, dynamic> metadata;
  final double confidence;
  final double importance;
  final double feedbackScore;
  final int accessCount;
  final DateTime createdAt;
  final DateTime lastAccessedAt;
  final String? sessionId;
  final String? userId;
  final String? conversationId;

  MemoryEntry({
    required this.id,
    required this.type,
    required this.content,
    this.metadata = const {},
    this.confidence = MemoryConstants.initialConfidence,
    this.importance = MemoryConstants.importanceDefault,
    this.feedbackScore = MemoryConstants.feedbackDefault,
    this.accessCount = 0,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    this.sessionId,
    this.userId,
    this.conversationId,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastAccessedAt = lastAccessedAt ?? DateTime.now();

  MemoryEntry copyWith({double? confidence, double? importance, double? feedbackScore, int? accessCount, DateTime? lastAccessedAt, Map<String, dynamic>? metadata}) {
    return MemoryEntry(id: id, type: type, content: content, metadata: metadata ?? this.metadata, confidence: confidence ?? this.confidence, importance: importance ?? this.importance, feedbackScore: feedbackScore ?? this.feedbackScore, accessCount: accessCount ?? this.accessCount, createdAt: createdAt, lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt, sessionId: sessionId, userId: userId, conversationId: conversationId);
  }

  bool get isExpired => confidence < MemoryConstants.minConfidence;
  bool get isCritical => importance >= 0.9;
  List<String> get tags {
    final t = metadata['tags'];
    if (t is List) return t.map((e) => e.toString()).toList();
    return [];
  }

  double get deletionScore {
    final normalizedAccess = (accessCount / 20.0).clamp(0.0, 0.1);
    final normalizedFeedback = ((feedbackScore + 1.0) / 2.0) * 0.15;
    double score = 0.0;
    score += confidence * 0.4;
    score += importance * 0.35;
    score += normalizedFeedback;
    score += normalizedAccess;
    if (isCritical) score += 10.0;
    if (feedbackScore < -0.5) score -= 0.3;
    return score;
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'type': type.nameValue, 'content': content, 'metadata': metadata,
        'confidence': confidence, 'importance': importance, 'feedbackScore': feedbackScore,
        'accessCount': accessCount, 'createdAt': createdAt.toIso8601String(),
        'lastAccessedAt': lastAccessedAt.toIso8601String(), 'sessionId': sessionId,
        'userId': userId, 'conversationId': conversationId,
      };

  factory MemoryEntry.fromJson(Map<String, dynamic> json) {
    return MemoryEntry(
      id: json['id'] as String,
      type: MemoryType.values.firstWhere((e) => e.nameValue == json['type'], orElse: () => MemoryType.episodic),
      content: json['content'] as String,
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>() ?? {},
      confidence: (json['confidence'] as num?)?.toDouble() ?? MemoryConstants.initialConfidence,
      importance: (json['importance'] as num?)?.toDouble() ?? MemoryConstants.importanceDefault,
      feedbackScore: (json['feedbackScore'] as num?)?.toDouble() ?? MemoryConstants.feedbackDefault,
      accessCount: json['accessCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastAccessedAt: json['lastAccessedAt'] != null ? DateTime.parse(json['lastAccessedAt']) : null,
      sessionId: json['sessionId'] as String?,
      userId: json['userId'] as String?,
      conversationId: json['conversationId'] as String?,
    );
  }
}
