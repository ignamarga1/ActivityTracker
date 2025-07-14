import 'dart:async';

import 'package:flutter/material.dart';
import 'package:activity_tracker_flutter/models/user.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;
  StreamSubscription<AppUser?>? _subscription;

  AppUser? get user => _user;

  UserProvider() {
    _startListening();
  }

  void _startListening() {
    final service = UserService();
    final userStream = service.streamCurrentUserData();

    _subscription = userStream.listen((appUser) {
      _user = appUser;
      notifyListeners();
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }

  void restart() {
    stopListening();
    _user = null;
    _startListening();
    notifyListeners();
  }
}
