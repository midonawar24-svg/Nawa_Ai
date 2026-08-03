import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
part 'drift_conversation_repository.g.dart';

class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get role => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Conversations])
class AppDatabase extends _$AppDatabase {
  AppDatabase(): super(driftDatabase(name: 'ai_core.db'));
  @override int get schemaVersion => 2;
  Future<void> addMessageDb(String role, String text) => into(conversations).insert(ConversationsCompanion.insert(role: role, content: text));
  Future<List<Conversation>> getRecent({int limit=10}) => (select(conversations)..orderBy([(t)=> OrderingTerm.desc(t.createdAt)])..limit(limit)).get();
}

class DriftConversationRepository {
  final AppDatabase db;
  DriftConversationRepository(this.db);
  Future<void> addMessage(String role, String text) => db.addMessageDb(role, text);
  Future<List<Map<String,String>>> getRecentHistory({int limit=10}) async {
    final rows = await db.getRecent(limit: limit);
    return rows.reversed.map((r)=> {'role': r.role, 'text': r.content}).toList();
  }
}
