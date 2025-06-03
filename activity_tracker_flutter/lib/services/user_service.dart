import 'package:activity_tracker_flutter/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  // Create new user
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
      );

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.uid)
          .set(newUser.toMap());
    }
  }
}
