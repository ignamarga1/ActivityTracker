import 'package:activity_tracker_flutter/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // SIGN UP
  Future<void> signUp({
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
    required BuildContext context,
  }) async {
    try {
      // Check if the username is being use already by other user
      final existingUser = await FirebaseFirestore.instance
          .collection("Users")
          .where("username", isEqualTo: username)
          .limit(1)
          .get();

      // Show error toast
      if (existingUser.docs.isNotEmpty) {
        Fluttertoast.showToast(
          msg: 'El nombre de usuario introducido ya se encuentra en uso',
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }

      // Create a new user
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Send email verification
      await _firebaseAuth.currentUser?.sendEmailVerification();

      // Save new user into Firestore
      await _userService.createUserDocument(
        userCredential: userCredential,
        username: username,
      );

      // Navigate to email verification page to wait for user verification
      await Future.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/emailVerification');

        if (_firebaseAuth.currentUser != null) {
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
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Ha ocurrido un error inesperado",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  // SIGN IN
  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Sign in with email and password
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to Home page after login
      await Future.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (Route<dynamic> route) => false,
        );

        if (_firebaseAuth.currentUser != null) {
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
      // User log out
      await _firebaseAuth.signOut();

      if (context.mounted) {
        Fluttertoast.showToast(
          msg: '¡Sesión cerrada con éxito!',
          toastLength: Toast.LENGTH_LONG,
        );

        // Clear app route stack leaving just the login page
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (Route<dynamic> route) => false,
        );
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
      // Reset password with email
      await _firebaseAuth.sendPasswordResetEmail(email: email);

      // Navigate back to login after the email is sent
      await Future.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        Navigator.pop(context);

        Fluttertoast.showToast(
          msg: 'Correo de restablecimiento enviado',
          toastLength: Toast.LENGTH_LONG,
        );
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

  // DELETE ACCOUNT
  Future<void> deleteAccount({required BuildContext context, required String password}) async {
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;

    try {
      // Authenticate again in case Firebase Aunthentication fails to delete the account
      final userCredentials = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(userCredentials);

      // Deletes the account from Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // Deletes the account from FirebaseAuth
      await user.delete();

      if (context.mounted) {
        Fluttertoast.showToast(
          msg: '¡Usuario eliminado con éxito!',
          toastLength: Toast.LENGTH_LONG,
        );

        // Clear app route stack leaving just the login page
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "No se ha podido eliminar la cuenta", toastLength: Toast.LENGTH_LONG);
    }
  }
}
