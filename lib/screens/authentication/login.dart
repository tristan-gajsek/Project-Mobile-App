import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_mobile_app/screens/app/profile.dart';
import 'package:project_mobile_app/screens/authentication/registration.dart';
import 'package:project_mobile_app/components/buttons.dart';
import 'package:project_mobile_app/components/text_field.dart';
import 'package:project_mobile_app/state.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
          CustomTextField(
            controller: usernameController,
            labelText: "Username",
            obscureText: false,
          ),
          CustomTextField(
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
          CustomButton(
            text: "Log in",
            onPressed: () async {
              var sharedState = Provider.of<SharedState>(
                context,
                listen: false,
              );
              sharedState.email = "foo@bar.com";
              sharedState.username = usernameController.text;

              final response = await http.post(
                Uri.parse("http://${sharedState.backendIp}:3001/users/login"),
                headers: <String, String>{
                  "Content-Type": "application/json; charset=UTF-8",
                },
                body: jsonEncode(<String, String>{
                  "username": usernameController.text,
                  "password": passwordController.text,
                }),
              );

              print(response.body);
              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                if (data["_id"] != null) {
                  sharedState.email = data["email"];
                  sharedState.username = data["username"];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                  return;
                }
              }

              usernameController.clear();
              passwordController.clear();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Login Failed"),
                    content: const Text("Username or password was incorrect."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
