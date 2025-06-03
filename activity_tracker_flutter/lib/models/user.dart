import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String _uid;
  final String _email;
  final String _username;
  final String _nickname;
  final String? _profilePictureURL;
  final Timestamp _createdAt;

  // Constructor
  AppUser({
    required String uid,
    required String email,
    required String username,
    required String nickname,
    String? profilePictureURL,
  }) : _uid = uid,
       _email = email,
       _username = username,
       _nickname = nickname,
       _profilePictureURL = profilePictureURL,
       _createdAt = Timestamp.now();

  // Getters
  String get uid => _uid;
  String get email => _email;
  String get username => _username;
  String get nickname => _nickname;
  String? get profilePictureURL => _profilePictureURL;
  Timestamp get createdAt => _createdAt;

  // Converts Firestore map into AppUser
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      nickname: map['nickname'] ?? '',
      profilePictureURL: map['profilePictureURL'],
    );
  }

  // Converts AppUser into map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': _uid,
      'email': _email,
      'username': _username,
      'nickname': _nickname,
      'profilePictureURL': _profilePictureURL ?? '',
      'createdAt': _createdAt,
    };
  }
}
