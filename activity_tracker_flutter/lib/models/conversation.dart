import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String _id;
  final String _user1Id;
  final String _user2Id;
  final Timestamp _createdAt;

  // Constructor
  Conversation({
    required String id,
    required String user1Id,
    required String user2Id,
    required Timestamp createdAt,
  }) : _id = id,
       _user1Id = user1Id,
       _user2Id = user2Id,
       _createdAt = createdAt;

  // Getters
  String get id => _id;
  String get user1Id => _user1Id;
  String get user2Id => _user2Id;
  Timestamp get createdAt => _createdAt;

  // Converts Firestore map into Conversation
  factory Conversation.fromMap(Map<String, dynamic> map, {required String id}) {
    return Conversation(
      id: id,
      user1Id: map['user1Id'],
      user2Id: map['user2Id'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  // Converts Conversation into map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user1Id': _user1Id,
      'user2Id': _user2Id,
      'createdAt': _createdAt,
    };
  }
}