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

  // brightness: Brightness.dark,
  // colorScheme: ColorScheme.dark(
  //   surface: Colors.grey.shade900,
  //   primary: Colors.grey.shade800,
  //   secondary: Colors.grey.shade700,
  //   inversePrimary: Colors.grey.shade300,
  // ),
  // textTheme: ThemeData.dark().textTheme.apply(
  //   bodyColor: Colors.grey[300],
  //   displayColor: Colors.white,
  // ),
);
