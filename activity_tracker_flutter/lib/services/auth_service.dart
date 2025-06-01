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

      // Navigate to Login page to log in with the new account
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/emailVerification');

        if (FirebaseAuth.instance.currentUser != null) {
          Fluttertoast.showToast(
            msg: '¡Cuenta creada con éxito!',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'La dirección de correo electrónico introducida no es válida';
      } else if (e.code == 'email-already-in-use') {
        message =
            'La dirección de correo electrónico introducida ya se encuentra en uso';
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
        Navigator.pushNamed(context, '/');

        if (FirebaseAuth.instance.currentUser != null) {
          Fluttertoast.showToast(
            msg: '¡Sesión iniciada con éxito!',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'La dirección de correo electrónico introducida no es válida';
      } else if (e.code == 'email-already-in-use') {
        message =
            'La dirección de correo electrónico introducida ya se encuentra en uso';
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
    try {
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Fluttertoast.showToast(
          msg: '¡Sesión cerrada con éxito!',
          toastLength: Toast.LENGTH_LONG,
        );

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'No se ha podido cerrar sesión',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  // RESET PASSWORD
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');

        if (FirebaseAuth.instance.currentUser != null) {
          Fluttertoast.showToast(
            msg: 'Correo de restablecimiento enviado',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'La dirección de correo electrónico introducida no es válida';
      } else if (e.code == 'user-not-found') {
        message =
            'La dirección de correo electrónico introducida no está asociada a ningún usuario';
      }
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
    }
  }
}
