import 'package:flutter/material.dart';
import 'package:project_mobile_app/globals.dart' as globals;

class AuthenticationTextField extends StatelessWidget {
  const AuthenticationTextField(
      {super.key,
      required this.controller,
      required this.labelText,
      required this.obscureText});

  final TextEditingController controller;
  final String labelText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(globals.padding),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
        ),
      ),
    );
  }
}
