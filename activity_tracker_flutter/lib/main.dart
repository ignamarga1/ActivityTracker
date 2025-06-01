import 'package:activity_tracker_flutter/pages/email_verification_page.dart';
import 'package:activity_tracker_flutter/pages/forgot_password_page.dart';
import 'package:activity_tracker_flutter/pages/home_page.dart';
import 'package:activity_tracker_flutter/pages/login_page.dart';
import 'package:activity_tracker_flutter/pages/register_page.dart';
import 'package:activity_tracker_flutter/themes/dark_mode.dart';
import 'package:activity_tracker_flutter/themes/light_mode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: ThemeMode.system,
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/',
      routes: {
        '/' : (context) => HomePage(),
        '/login' : (context) => LoginPage(),
        '/register' : (context) => RegisterPage(),
        '/emailVerification' : (context) => EmailVerificationPage(),
        '/forgotPassword' : (context) => ForgotPasswordPage(),
      },
    );
  }
}