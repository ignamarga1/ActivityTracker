import 'package:activity_tracker_flutter/themes/custom_page_transition.dart';
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  hintColor: Colors.grey[700],
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: Colors.blue.shade800,
    secondary: Colors.blue.shade400,
    inversePrimary: Colors.blue.shade200,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey[900],
    displayColor: Colors.black,
  ),

  pageTransitionsTheme: PageTransitionsTheme(
    builders: {TargetPlatform.android: CustomPageTransition()},
  ),

);