import 'package:activity_tracker_flutter/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final _collection = FirebaseFirestore.instance.collection('Messages');

  // Create message (send)
  Future<void> sendMessage({required String conversationId, required String userId, required String text}) async {
    final docRef = _collection.doc();

    final message = Message(
      id: docRef.id,
      conversationId: conversationId,
      userId: userId,
      text: text,
      createdAt: Timestamp.now(),
    );

    await docRef.set(message.toMap());
  }

  // Stream with the messages of a conversation
  Stream<List<Message>> getMessagesForConversation(String conversationId) {
    return _collection
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Message.fromMap(doc.data(), id: doc.id);
          }).toList();
        });
  }

  // Stream with the last message of a conversation (if there are any messages)
  Stream<Message?> getLastMessage(String conversationId) {
    return _collection
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return Message.fromMap(doc.data(), id: doc.id);
        });
  }
}
