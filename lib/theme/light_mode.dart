import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      primary: Colors.grey.shade200,
      background: Colors.grey.shade300,
      secondary: Colors.grey.shade400,
      inversePrimary: Colors.grey.shade800),
  textTheme: ThemeData.light()
      .textTheme
      .apply(displayColor: Colors.black, bodyColor: Colors.grey),
);
