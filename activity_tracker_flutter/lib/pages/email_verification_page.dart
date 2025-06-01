import 'dart:async';

import 'package:activity_tracker_flutter/components/std_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  late Timer timer;
  bool _isCheckingVerification = true;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      // Checks if the user has confirm the email
      FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && FirebaseAuth.instance.currentUser!.emailVerified) {
        timer.cancel();

        if (mounted) {
          setState(() {
            _isCheckingVerification = false;
          });
        }

        Navigator.pushNamed(context, '/login');
        Fluttertoast.showToast(
          msg: '¡Cuenta verificada con éxito!',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Text("Activity Tracker", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),

              // Information text
              Text(
                "Te hemos enviado un email a la dirección de correo electrónico indicada para que la verifiques y puedas usar tu cuenta",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 30),

              if (_isCheckingVerification) ...[
                CircularProgressIndicator(),
                const SizedBox(height: 15),
                Text(
                  "Esperando verificación...",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
              const SizedBox(height: 40),

              // Sign up button
              StdButton(
                text: "Volver a enviar",
                onPressed: () async {
                  // Sends again the verification email
                  await FirebaseAuth.instance.currentUser
                      ?.sendEmailVerification();
                  Fluttertoast.showToast(
                    msg: 'Correo de verificación reenviado',
                    toastLength: Toast.LENGTH_LONG,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
