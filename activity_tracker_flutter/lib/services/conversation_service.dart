import 'package:activity_tracker_flutter/models/conversation.dart';
import 'package:activity_tracker_flutter/services/message_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationService {
  final _collection = FirebaseFirestore.instance.collection('Conversations');

  // Creates a unique ID with the users IDs
  String _generateDocId(String user1Id, String user2Id) {
    final sortedIds = [user1Id, user2Id]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Create conversation between two users
  Future<Conversation> createConversation(String user1Id, String user2Id) async {
    final docId = _generateDocId(user1Id, user2Id);
    final doc = await _collection.doc(docId).get();

    if (doc.exists) {
      return Conversation.fromMap(doc.data()!, id: doc.id);
    }

    final newConversation = Conversation(id: docId, user1Id: user1Id, user2Id: user2Id, createdAt: Timestamp.now());

    await _collection.doc(docId).set(newConversation.toMap());
    return newConversation;
  }

  // Stream to get all the users conversations
  Stream<List<Conversation>> getUserConversations(String userId) {
    final user1Stream = _collection.where('user1Id', isEqualTo: userId).snapshots();
    final user2Stream = _collection.where('user2Id', isEqualTo: userId).snapshots();

    return user1Stream.asyncMap((user1Snapshot) async {
      final user2Snapshot = await user2Stream.first;

      final allDocs = [...user1Snapshot.docs, ...user2Snapshot.docs];
      final conversations = allDocs.map((doc) {
        return Conversation.fromMap(doc.data(), id: doc.id);
      }).toList();

      return conversations;
    });
  }

  // Deletes a conversation between two users (and the messages if there are any)
  Future<void> deleteConversationBetweenUsers(String user1Id, String user2Id) async {
    final docId = _generateDocId(user1Id, user2Id);
    final doc = await _collection.doc(docId).get();

    // Checks if the conversation exists to delete its messages and then the conversation
    if (doc.exists) {
      await MessageService().deleteMessagesByConversationId(docId);
      await _collection.doc(docId).delete();
    }
  }
}
