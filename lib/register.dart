import 'package:flutter/material.dart';
import 'package:project_mobile_app/login.dart';

const double padding = 10;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _email = "";
  String _username = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Register"),
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
                      builder: (context) => const LoginScreen())),
              child: const Text("Log in"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(padding),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "E-mail",
              ),
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
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
              onPressed: () {},
              child: const Text("Register"),
            ),
          ),
        ],
      ),
    );
  }
}
