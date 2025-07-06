import 'package:activity_tracker_flutter/themes/custom_page_transition.dart';
import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  hintColor: Colors.grey[700],
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.blue.shade800,
    secondary: Colors.blue.shade400,
    inversePrimary: Colors.blue.shade200,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey[300],
    displayColor: Colors.white,
  ),

  pageTransitionsTheme: PageTransitionsTheme(
    builders: {TargetPlatform.android: CustomPageTransition()},
  ),
);
