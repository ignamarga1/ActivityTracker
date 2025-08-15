import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

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
        StdFluttertoast.show(
          'El nombre de usuario introducido ya se encuentra en uso',
          Toast.LENGTH_LONG,
          ToastGravity.BOTTOM,
        );
        return;
      }

      // Create a new user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      // Send email verification
      await _firebaseAuth.currentUser?.sendEmailVerification();

      // Save new user into Firestore
      await _userService.createUser(userCredential: userCredential, username: username);

      // Restart UserProvider
      if (context.mounted) {
        Provider.of<UserProvider>(context, listen: false).restart();
      }

      // Navigate to email verification page to wait for user verification
      await Future.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/emailVerification');

        if (_firebaseAuth.currentUser != null) {
          StdFluttertoast.show('¡Cuenta creada con éxito!', Toast.LENGTH_LONG, ToastGravity.BOTTOM);
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'La dirección de correo electrónico introducida no es válida';
      } else if (e.code == 'email-already-in-use') {
        message = 'La dirección de correo electrónico introducida ya se encuentra en uso';
      } else if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil';
      }
      StdFluttertoast.show(message, Toast.LENGTH_LONG, ToastGravity.BOTTOM);
    } catch (e) {
      StdFluttertoast.show('Ha ocurrido un error inesperado', Toast.LENGTH_LONG, ToastGravity.BOTTOM);
    }
  }

  // SIGN IN
  Future<void> signIn({required String email, required String password, required BuildContext context}) async {
    try {
      // Loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Sign in with email and password
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      if (context.mounted) {
        // Restart UserProvider
        Provider.of<UserProvider>(context, listen: false).restart();

        // Pops loading dialog
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }

      // Navigate to Home page after login
      await Future.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);

        StdFluttertoast.show('¡Sesión iniciada con éxito!', Toast.LENGTH_SHORT, ToastGravity.BOTTOM);
      }
    } on FirebaseAuthException catch (e) {
      // Pops loading dialog when there is an error
      if (context.mounted) {
        Navigator.pop(context);
      }

      String message = '';

      if (e.code == 'invalid-email') {
        message = 'La dirección de correo electrónico introducida no es válida';
      } else if (e.code == 'email-already-in-use') {
        message = 'La dirección de correo electrónico introducida ya se encuentra en uso';
      } else if (e.code == 'user-not-found') {
        message = 'La dirección de correo electrónico introducida no está asociada a ningún usuario';
      } else if (e.code == 'wrong-password') {
        message = 'La contraseña introducida es incorrecta';
      } else if (e.code == 'invalid-credential') {
        message = 'Las credenciales son incorrectas';
      }
      StdFluttertoast.show(message, Toast.LENGTH_LONG, ToastGravity.BOTTOM);
    }
  }

  // LOG OUT
  Future<void> logOut({required BuildContext context}) async {
    try {
      // User log out
      await _firebaseAuth.signOut();

      // Restart UserProvider
      if (context.mounted) {
        Provider.of<UserProvider>(context, listen: false).restart();

        // Clear app route stack leaving just the login page
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);

        StdFluttertoast.show('¡Sesión cerrada con éxito!', Toast.LENGTH_SHORT, ToastGravity.BOTTOM);
      }
    } catch (e) {
      StdFluttertoast.show('No se ha podido cerrar sesión', Toast.LENGTH_LONG, ToastGravity.BOTTOM);
    }
  }

  // RESET PASSWORD
  Future<void> resetPassword({required String email, required BuildContext context}) async {
    try {
      // Reset password with email
      await _firebaseAuth.sendPasswordResetEmail(email: email);

      // Navigate back to login after the email is sent
      await Future.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        Navigator.pop(context);

        StdFluttertoast.show('Correo de restablecimiento enviado', Toast.LENGTH_LONG, ToastGravity.BOTTOM);
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'La dirección de correo electrónico introducida no es válida';
      } else if (e.code == 'user-not-found') {
        message = 'La dirección de correo electrónico introducida no está asociada a ningún usuario';
      }
      StdFluttertoast.show(message, Toast.LENGTH_LONG, ToastGravity.BOTTOM);
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount({required BuildContext context, required String password}) async {
    final user = _firebaseAuth.currentUser!;

    try {
      // Authenticate again in case Firebase Aunthentication fails to delete the account
      final userCredentials = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(userCredentials);

      // Delete the account from Firestore
      await _userService.deleteCurrentUser();

      // Delete the account from FirebaseAuth
      await user.delete();

      // Restart UserProvider
      if (context.mounted) {
        Provider.of<UserProvider>(context, listen: false).restart();
      }

      if (context.mounted) {
        // Clear app route stack leaving just the login page
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);

        StdFluttertoast.show('¡Usuario eliminado con éxito!', Toast.LENGTH_LONG, ToastGravity.BOTTOM);
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-credential') {
        message = 'Las credenciales son incorrectas';
      }
      StdFluttertoast.show(message, Toast.LENGTH_LONG, ToastGravity.BOTTOM);
    } catch (e) {
      StdFluttertoast.show('No se ha podido eliminar la cuenta', Toast.LENGTH_LONG, ToastGravity.BOTTOM);
    }
  }
}
