import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, accepted, rejected }

class ChallengeRequest {
  final String _id;
  final String _senderUserId;
  final String _receiverUserId;
  final String _challengeActivityId;
  final RequestStatus _status;
  final Timestamp _createdAt;

  // Constructor
  ChallengeRequest({
    required String id,
    required String senderUserId,
    required String receiverUserId,
    required String challengeActivityId,
    RequestStatus status = RequestStatus.pending,
    required Timestamp createdAt,
  }) : _id = id,
       _senderUserId = senderUserId,
       _receiverUserId = receiverUserId,
       _challengeActivityId = challengeActivityId,
       _status = status,
       _createdAt = createdAt;

  // Getters
  String get id => _id;
  String get senderUserId => _senderUserId;
  String get receiverUserId => _receiverUserId;
  String get challengeActivityId => _challengeActivityId;
  RequestStatus get status => _status;
  Timestamp get createdAt => _createdAt;

  // Enum helper
  static T _enumFromString<T>(List<T> values, String value) =>
      values.firstWhere((e) => e.toString().split('.').last == value);

  // Converts Firestore map into ChallengeRequest
  factory ChallengeRequest.fromMap(Map<String, dynamic> map, {required String id}) {
    return ChallengeRequest(
      id: id,
      senderUserId: map['senderUserId'],
      receiverUserId: map['receiverUserId'],
      challengeActivityId: map['challengeActivityId'],
      status: _enumFromString(RequestStatus.values, map['status']),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  // Converts ChallengeRequest into map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderUserId': _senderUserId,
      'receiverUserId': _receiverUserId,
      'challengeActivityId': _challengeActivityId,
      'status': _status.name,
      'createdAt': _createdAt,
    };
  }
}
