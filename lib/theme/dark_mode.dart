import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
      primary: Colors.grey.shade800,
      background: Colors.grey.shade900,
      secondary: Colors.grey.shade700,
      inversePrimary: Colors.grey.shade500),
  textTheme: ThemeData.dark().textTheme.apply(
        displayColor: Colors.white,
        bodyColor: Colors.grey,
      ),
);
