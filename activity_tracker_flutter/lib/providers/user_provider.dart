import 'package:flutter/material.dart';
import 'package:activity_tracker_flutter/models/user.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;

  AppUser? get user => _user;

  Future<void> loadUser() async {
    _user = await UserService().getCurrentUserData();
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final updatedUser = await UserService().getCurrentUserData();
    if(updatedUser != null) {
      _user = updatedUser;
      notifyListeners();
    }
  }
}
