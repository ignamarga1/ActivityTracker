import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String _id;
  final String _conversationId;
  final String _userId;
  final String _text;
  final Timestamp _createdAt;

  // Constructor
  Message({
    required String id,
    required String conversationId,
    required String userId,
    required String text,
    required Timestamp createdAt,
  }) : _id = id,
       _conversationId = conversationId,
       _userId = userId,
       _text = text,
       _createdAt = createdAt;

  // Getters
  String get id => _id;
  String get conversationId => _conversationId;
  String get userId => _userId;
  String get text => _text;
  Timestamp get createdAt => _createdAt;

  // Converts Firestore map into Conversation
  factory Message.fromMap(Map<String, dynamic> map, {required String id}) {
    return Message(
      id: id,
      conversationId: map['conversationId'],
      userId: map['userId'],
      text: map['text'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  // Converts Conversation into map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'conversationId': _conversationId,
      'userId': _userId,
      'text': _text,
      'createdAt': _createdAt,
    };
  }
}