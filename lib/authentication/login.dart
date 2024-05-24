import 'package:flutter/material.dart';
import 'package:project_mobile_app/app/profile.dart';
import 'package:project_mobile_app/authentication/button.dart';
import 'package:project_mobile_app/authentication/registration.dart';
import 'package:project_mobile_app/authentication/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Login"),
        ),
      ),
      body: Column(
        children: [
          AuthenticationTextField(
            controller: usernameController,
            labelText: "Username",
            obscureText: false,
          ),
          AuthenticationTextField(
            controller: passwordController,
            labelText: "Password",
            obscureText: true,
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            ),
            child: const Text("Don't have an account?"),
          ),
          AuthenticationButton(
            text: "Log in",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  email: "foo@bar.com",
                  username: usernameController.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
