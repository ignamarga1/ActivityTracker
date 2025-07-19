import 'package:activity_tracker_flutter/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _collection = FirebaseFirestore.instance.collection('Users');

  // Create new user document in Firestore
  Future<void> createUserDocument({required UserCredential? userCredential, required String username}) async {
    final user = userCredential?.user;

    if (user != null) {
      // Create the user
      final newUser = AppUser(
        uid: user.uid,
        email: user.email!,
        username: username,
        nickname: username,
        createdAt: Timestamp.now(),
      );

      await _collection.doc(user.uid).set(newUser.toMap());
    }
  }

  // Get current user data
  Stream<AppUser?> streamCurrentUserData() {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }

    return _collection.doc(currentUser.uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return AppUser.fromMap(snapshot.data()!);
    });
  }

  // Get user data by user id
  Stream<AppUser?> getUserById(String uid) {
  return _collection.doc(uid).snapshots().map((doc) {
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  });
}


  // Get user data by username
  Future<String?> getUserIdByUsername(String username) async {
    final querySnapshot = await _collection.where('username', isEqualTo: username).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return null;
    }
  }

  // Delete user
  Future<void> deleteUserDocument() async {
    // Current user that has logged in
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser != null) {
      await _collection.doc(currentUser.uid).delete();
    }
  }

  // Update user profile data
  Future<void> updateUserDocument({String? newNickname, String? newImageUrl}) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser != null) {
      final Map<String, dynamic> profileDataToUpdate = {};

      if (newNickname != null && newNickname.isNotEmpty) {
        profileDataToUpdate['nickname'] = newNickname;
      }

      if (newImageUrl != null && newImageUrl.isNotEmpty) {
        profileDataToUpdate['profilePictureURL'] = newImageUrl;
      }

      if (profileDataToUpdate.isNotEmpty) {
        await _collection.doc(currentUser.uid).update(profileDataToUpdate);
      }
    }
  }
}
