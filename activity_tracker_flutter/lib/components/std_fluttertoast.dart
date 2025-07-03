import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StdFluttertoast {
  static void show(String message, Toast toastLength, ToastGravity gravity) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }
}
