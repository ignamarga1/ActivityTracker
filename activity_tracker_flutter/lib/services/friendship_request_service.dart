import 'package:activity_tracker_flutter/models/friendship_request.dart';
import 'package:activity_tracker_flutter/services/conversation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class FriendshipRequestService {
  final _collection = FirebaseFirestore.instance.collection('FriendshipRequest');

  // Helper method to check if the friendship request already exists
  Future<bool> doesFriendshipRequestExist(String userId1, String userId2) async {
    final query = await _collection
        .where('senderUserId', whereIn: [userId1, userId2])
        .where('receiverUserId', whereIn: [userId1, userId2])
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

  // Create a new friend request between two users
  Future<void> createFriendshipRequest({
    required String senderUserId,
    required String receiverUserId,
    required Timestamp createdAt,
  }) async {
    final docRef = _collection.doc();
    final newFriendshipRequest = FriendshipRequest(
      id: docRef.id,
      senderUserId: senderUserId,
      receiverUserId: receiverUserId,
      createdAt: createdAt,
    );

    final existsFriendshipRequest = await doesFriendshipRequestExist(senderUserId, receiverUserId);

    if (!existsFriendshipRequest) {
      await docRef.set(newFriendshipRequest.toMap());
    }
  }

  // Get list of sent friendship requests by the user (ordered by creation date, newer to older)
  Stream<List<FriendshipRequest>> getUserSentFriendshipRequests(String userId) {
    return _collection
        .where("senderUserId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FriendshipRequest.fromMap(doc.data(), id: doc.id)).toList());
  }

  // Get a user's list of received friendship requests (ordered by creation date, newer to older)
  Stream<List<FriendshipRequest>> getUserReceivedFriendshipRequests(String userId) {
    return _collection
        .where("receiverUserId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FriendshipRequest.fromMap(doc.data(), id: doc.id)).toList());
  }

  // Get friendship request by id
  Stream<FriendshipRequest> getFriendshipRequestById(String id) {
    return _collection.doc(id).snapshots().map((snapshot) {
      return FriendshipRequest.fromMap(snapshot.data()!, id: snapshot.id);
    });
  }

  // Get a user's list of friends (those with an accepted request)
  Stream<List<FriendshipRequest>> getUserFriends(String userId) {
    final sentFriendshipRequestStream = _collection
        .where('senderUserId', isEqualTo: userId)
        .where('status', isEqualTo: RequestStatus.accepted.name)
        .snapshots();

    final receivedFriendshipRequestStream = _collection
        .where('receiverUserId', isEqualTo: userId)
        .where('status', isEqualTo: RequestStatus.accepted.name)
        .snapshots();

    return Rx.combineLatest2(sentFriendshipRequestStream, receivedFriendshipRequestStream, (sentSnap, receivedSnap) {
      final sent = sentSnap.docs.map((doc) => FriendshipRequest.fromMap(doc.data(), id: doc.id)).toList();
      final received = receivedSnap.docs.map((doc) => FriendshipRequest.fromMap(doc.data(), id: doc.id)).toList();

      return [...sent, ...received];
    });
  }

  // Update friendship request status
  Future<void> updateFriendshipRequest({required String id, required RequestStatus status}) async {
    final Map<String, dynamic> data = {};
    data['status'] = status.name;

    await _collection.doc(id).update(data);
  }

  // Delete friendship request
  Future<void> deleteFriendshipRequestById(String id) async {
    await _collection.doc(id).delete();
  }

  // Delete friendship request
  Future<void> deleteFriend(String user1Id, String user2Id) async {
    // Deletes the accepted friendship request between the users
    final query = await _collection
        .where('senderUserId', whereIn: [user1Id, user2Id])
        .where('receiverUserId', whereIn: [user1Id, user2Id])
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

    // Deletes the conversation and the messages (if they exist)
    await ConversationService().deleteConversationBetweenUsers(user1Id, user2Id);
  }
}
