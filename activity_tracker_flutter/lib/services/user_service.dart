import 'package:activity_tracker_flutter/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Create new user document in Firestore
  Future<void> createUserDocument({
    required UserCredential? userCredential,
    required String username,
  }) async {
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

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.uid)
          .set(newUser.toMap());
    }
  }

  // Get current user data
  Stream<AppUser?> streamCurrentUserData() {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }

    return FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return AppUser.fromMap(snapshot.data()!);
        });
  }

  // Delete user
  Future<void> deleteUserDocument() async {
    // Current user that has logged in
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser.uid)
          .delete();
    }
  }

  // Update user profile data
  Future<void> updateUserDocument({
    String? newNickname,
    String? newImageUrl,
  }) async {
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
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.uid)
            .update(profileDataToUpdate);
      }
    }
  }
}
