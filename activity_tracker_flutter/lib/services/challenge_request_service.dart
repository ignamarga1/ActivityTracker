import 'package:activity_tracker_flutter/models/challenge_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeRequestService {
  final _collection = FirebaseFirestore.instance.collection('ChallengeRequest');

  // Helper method to check if the challenge request already exists
  Future<bool> doesChallengeRequestExist(String userId1, String userId2, String challengeActivityId) async {
    final query = await _collection
        .where('challengeActivityId', isEqualTo: challengeActivityId)
        .where('status', whereIn: ['pending', 'accepted'])
        .get();

    for (final doc in query.docs) {
      final data = doc.data();
      final sender = data['senderUserId'];
      final receiver = data['receiverUserId'];

      if ((sender == userId1 && receiver == userId2) || (sender == userId2 && receiver == userId1)) {
        return true;
      }
    }

    return false;
  }

  // Create a new challenge request between two users for the selected activity
  Future<void> createChallengeRequest({
    required String senderUserId,
    required String receiverUserId,
    required String challengeActivityId,
    required Timestamp createdAt,
  }) async {
    final docRef = _collection.doc();
    final newChallengeRequest = ChallengeRequest(
      id: docRef.id,
      senderUserId: senderUserId,
      receiverUserId: receiverUserId,
      challengeActivityId: challengeActivityId,
      createdAt: createdAt,
    );

    final existsChallengeRequest = await doesChallengeRequestExist(senderUserId, receiverUserId, challengeActivityId);

    if (!existsChallengeRequest) {
      await docRef.set(newChallengeRequest.toMap());
    }
  }

  // Get list of sent challenge requests by the user (ordered by creation date, newer to older)
  Stream<List<ChallengeRequest>> getUserSentChallengeRequests(String userId) {
    return _collection
        .where("senderUserId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChallengeRequest.fromMap(doc.data(), id: doc.id)).toList());
  }

  // Get a user's list of received challenge requests (ordered by creation date, newer to older)
  Stream<List<ChallengeRequest>> getUserReceivedChallengeRequests(String userId) {
    return _collection
        .where("receiverUserId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChallengeRequest.fromMap(doc.data(), id: doc.id)).toList());
  }

  // Get an user's list of challenges (those with an accepted request, ordered by creation date, newer to older)
  Stream<List<ChallengeRequest>> getUserChallenges(String userId) {
    return _collection
        .where('receiverUserId', isEqualTo: userId)
        .where('status', isEqualTo: RequestStatus.accepted.name)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => ChallengeRequest.fromMap(doc.data(), id: doc.id)).toList();
        });
  }

  // Get challenge request by id
  Stream<ChallengeRequest> getChallengeRequestById(String id) {
    return _collection.doc(id).snapshots().map((snapshot) {
      return ChallengeRequest.fromMap(snapshot.data()!, id: snapshot.id);
    });
  }

  // Update challenge request status
  Future<void> updateChallengeRequest({required String id, required RequestStatus status}) async {
    final Map<String, dynamic> data = {};
    data['status'] = status.name;

    await _collection.doc(id).update(data);
  }

  // Delete a challenge request
  Future<void> deleteChallengeRequestById(String id) async {
    await _collection.doc(id).delete();
  }

  // Delete an accepted challenge request between two user
  Future<void> deleteChallenge(String user1Id, String user2Id, String challengeActivityId) async {
    // Deletes the accepted challenge request between the users
    final query = await _collection
        .where('challengeActivityId', isEqualTo: challengeActivityId)
        .where('status', isEqualTo: RequestStatus.accepted.name)
        .get();

    for (final doc in query.docs) {
      final data = doc.data();
      final sender = data['senderUserId'];
      final receiver = data['receiverUserId'];

      if ((sender == user1Id && receiver == user2Id) || (sender == user2Id && receiver == user1Id)) {
        await _collection.doc(doc.id).delete();
      }
    }
  }
}
