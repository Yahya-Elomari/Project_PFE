import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hinttext;
  final bool obscureText;
  final TextEditingController controller;
  const MyTextField({super.key,
  required this.hinttext,
  required this.obscureText,
  required this.controller,});


  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: hinttext,
      ),
      obscureText: obscureText,
    );
  }
}