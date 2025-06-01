import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  // SIGN UP
  Future<void> signUp({
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
    required BuildContext context,
  }) async {
    try {
      // Creates a new user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sends email verification
      FirebaseAuth.instance.currentUser?.sendEmailVerification();

      // Navigate to Login page to login with the new account
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'El email introducido no es un email válido';
      } else if (e.code == 'email-already-in-use') {
        message = 'El email introducido ya se encuentra en uso';
      } else if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil';
      }
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
    }
  }

  // SIGN IN
  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Creates a new user
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to Home page
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Navigator.popAndPushNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'El email introducido no es un email válido';
      } else if (e.code == 'email-already-in-use') {
        message = 'El email introducido ya se encuentra en uso';
      } else if (e.code == 'user-not-found') {
        message =
            'La dirección de correo electrónico introducida no está asociada a ningún usuario';
      } else if (e.code == 'wrong-password') {
        message = 'La contraseña introducida es incorrecta';
      } else if (e.code == 'invalid-credential') {
        message = 'Las credenciales son incorrectas';
      }
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
    }
  }

  // LOG OUT
  Future<void> logOut({required BuildContext context}) async {
    FirebaseAuth.instance.signOut();
  }
}
