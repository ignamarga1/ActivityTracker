import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, accepted, rejected }

class FriendshipRequest {
  final String _id;
  final String _senderUserId;
  final String _receiverUserId;
  final RequestStatus _status;
  final Timestamp _createdAt;

  // Constructor
  FriendshipRequest({
    required String id,
    required String senderUserId,
    required String receiverUserId,
    RequestStatus status = RequestStatus.pending,
    required Timestamp createdAt,
  }) : _id = id,
       _senderUserId = senderUserId,
       _receiverUserId = receiverUserId,
       _status = status,
       _createdAt = createdAt;

  // Getters
  String get id => _id;
  String get senderUserId => _senderUserId;
  String get receiverUserId => _receiverUserId;
  RequestStatus get status => _status;
  Timestamp get createdAt => _createdAt;

  // Enum helper
  static T _enumFromString<T>(List<T> values, String value) =>
      values.firstWhere((e) => e.toString().split('.').last == value);

  // Converts Firestore map into FriendshipRequest
  factory FriendshipRequest.fromMap(Map<String, dynamic> map, {required String id}) {
    return FriendshipRequest(
      id: id,
      senderUserId: map['senderUserId'],
      receiverUserId: map['receiverUserId'],
      status: _enumFromString(RequestStatus.values, map['status']),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  // Converts FriendshipRequest into map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderUserId': _senderUserId,
      'receiverUserId': _receiverUserId,
      'status': _status.name,
      'createdAt': _createdAt,
    };
  }
}
