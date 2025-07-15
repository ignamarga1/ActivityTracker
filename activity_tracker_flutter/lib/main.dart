import 'package:activity_tracker_flutter/pages/activities/activity_details_page.dart';
import 'package:activity_tracker_flutter/pages/activities/create_activity_page.dart';
import 'package:activity_tracker_flutter/pages/activities/create_template_activity.dart';
import 'package:activity_tracker_flutter/pages/activities/edit_activity_page.dart';
import 'package:activity_tracker_flutter/pages/activities/select_template_activity.dart';
import 'package:activity_tracker_flutter/pages/challenges/challenges_page.dart';
import 'package:activity_tracker_flutter/pages/home_page.dart';
import 'package:activity_tracker_flutter/pages/login_register/email_verification_page.dart';
import 'package:activity_tracker_flutter/pages/login_register/forgot_password_page.dart';
import 'package:activity_tracker_flutter/pages/friends/friends_page.dart';
import 'package:activity_tracker_flutter/pages/login_register/login_page.dart';
import 'package:activity_tracker_flutter/pages/messages/messages_page.dart';
import 'package:activity_tracker_flutter/pages/login_register/register_page.dart';
import 'package:activity_tracker_flutter/pages/settings_page.dart';
import 'package:activity_tracker_flutter/pages/user_profile/edit_user_profile_page.dart';
import 'package:activity_tracker_flutter/pages/user_profile/user_profile_page.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/themes/dark_mode.dart';
import 'package:activity_tracker_flutter/themes/light_mode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Normal Portrait
  ]);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: ThemeMode.system,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('es'), // Spanish
      ],
      //home: AuthGate(), 
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/',

      routes: {
        // USERS
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/emailVerification': (context) => EmailVerificationPage(),
        '/forgotPassword': (context) => ForgotPasswordPage(),
        '/editUserProfile': (context) => EditUserProfilePage(),

        // DRAWER ROUTER OPTIONS
        '/userProfile': (context) => UserProfilePage(),
        '/friends': (context) => FriendsPage(),
        '/messages': (context) => MessagesPage(),
        '/challenges': (context) => ChallengesPage(),
        '/settings': (context) => SettingsPage(),

        // ACTIVITIES
        '/createActivity': (context) => CreateActivityPage(),
        '/selectTemplateActivity': (context) => SelectTemplateActivityPage(),
        '/createTemplateActivity': (context) => CreateTemplateActivityPage(),
        '/activityDetails': (context) => ActivityDetailsPage(),
        '/editActivity': (context) => EditActivityPage(),
      },
    );
  }
}
