import 'package:flutter/material.dart';
import 'package:project_mobile_app/app/profile.dart';
import 'package:project_mobile_app/authentication/button.dart';
import 'package:project_mobile_app/authentication/login.dart';
import 'package:project_mobile_app/authentication/text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Registration"),
        ),
      ),
      body: Column(
        children: [
          AuthenticationTextField(
            controller: emailController,
            labelText: "E-mail",
            obscureText: false,
          ),
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
                builder: (context) => const LoginScreen(),
              ),
            ),
            child: const Text("Already have an account?"),
          ),
          AuthenticationButton(
            text: "Register",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  email: emailController.text,
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
