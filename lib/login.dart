import 'package:flutter/material.dart';
import 'package:project_mobile_app/profile.dart';
import 'package:project_mobile_app/register.dart';

const double padding = 10;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _username = "";
  String _password = "";

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
          Padding(
            padding: const EdgeInsets.all(padding),
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen())),
              child: const Text("Register"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(padding),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Username",
              ),
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(padding),
            child: TextField(
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Password",
              ),
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(padding),
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                          email: "foo@bar.com", username: _username))),
              child: const Text("Log in"),
            ),
          ),
        ],
      ),
    );
  }
}
