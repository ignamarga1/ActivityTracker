import 'dart:async';

import 'package:activity_tracker_flutter/components/std_button.dart';
import 'package:activity_tracker_flutter/components/std_fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late Timer timer;
  bool _isCheckingVerification = true;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Checks if the user has confirm the email
      _firebaseAuth.currentUser?.reload();
      final user = _firebaseAuth.currentUser;

      if (user != null && _firebaseAuth.currentUser!.emailVerified) {
        timer.cancel();

        if (mounted) {
          setState(() {
            _isCheckingVerification = false;
          });
        }

        Navigator.pushReplacementNamed(context, '/login');
        StdFluttertoast.show('¡Cuenta verificada con éxito!', Toast.LENGTH_SHORT, ToastGravity.BOTTOM);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          // No hacemos nada
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        resizeToAvoidBottomInset: false,
        body: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App name
                SvgPicture.asset(
                  'assets/activity_tracker_logo.svg',
                  width: 65,
                  height: 65,
                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                ),
                const SizedBox(height: 20),

                // Information text
                Text(
                  "Te hemos enviado un email a la dirección de correo electrónico indicada para que la verifiques y puedas usar tu cuenta",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 30),

                if (_isCheckingVerification) ...[
                  CircularProgressIndicator(),
                  const SizedBox(height: 15),
                  Text(
                    "Esperando verificación...",
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
                const SizedBox(height: 30),

                // Send email again button
                StdButton(
                  text: "Volver a enviar",
                  onPressed: () async {
                    // Sends again the verification email
                    await _firebaseAuth.currentUser?.sendEmailVerification();
                    StdFluttertoast.show('Correo de verificación reenviado', Toast.LENGTH_SHORT, ToastGravity.BOTTOM);
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
