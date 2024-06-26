import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project_mobile_app/components/dialog.dart';
import 'package:project_mobile_app/screens/app/profile.dart';
import 'package:project_mobile_app/screens/authentication/login.dart';
import 'package:project_mobile_app/screens/authentication/video.dart';
import 'package:project_mobile_app/components/buttons.dart';
import 'package:project_mobile_app/components/text_field.dart';
import 'package:project_mobile_app/state.dart';
import 'package:provider/provider.dart';
import "package:http/http.dart" as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  File? selectedVideo;
  var result;

  Future<void> uploadVideo(File image) async {
    var sharedState = Provider.of<SharedState>(
      context,
      listen: false,
    );

    var request = http.MultipartRequest('POST', Uri.parse('http://${sharedState.backendIp}:5000/face-recognition/authenticate'));
    request.fields['purpose'] = 'train';
    // debugPrint("USER ID: $userId");
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      result = jsonDecode(responseData);
      debugPrint(result['result']);
      return;
    } else {
      debugPrint("API RETURNED ERROR");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    var sharedState = Provider.of<SharedState>(context);
    sharedState.email = emailController.text;
    sharedState.username = usernameController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Registration"),
        ),
      ),
      body: Column(
        children: [
          CustomTextField(
            controller: emailController,
            labelText: "E-mail",
            obscureText: false,
          ),
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
                builder: (context) => const LoginScreen(),
              ),
            ),
            child: const Text("Already have an account?"),
          ),
          CustomButton(
            text: "Register",
            onPressed: () async {
              if (emailController.text.isEmpty ||
                  usernameController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                showCustomDialog(
                  context,
                  "Registration Failed",
                  "Make sure to fill out everything.",
                  "OK",
                );
                return;
              }

              var sharedState = Provider.of<SharedState>(
                context,
                listen: false,
              );

              final response = await sharedState.httpClient.post(
                Uri.parse("http://${sharedState.backendIp}:3001/users"),
                headers: {"Content-Type": "application/json; charset=UTF-8"},
                body: jsonEncode({
                  "email": emailController.text,
                  "username": usernameController.text,
                  "password": passwordController.text,
                }),
              );

              File ? selectedVideo = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoScreen(),
                ),
              );

              if (response.statusCode == 201) {
                final data = jsonDecode(response.body);
                if (data["_id"] != null) {
                  sharedState.email = data["email"];
                  sharedState.username = data["username"];
                  //uploadVideo(selectedVideo!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                  return;
                }
              }

              emailController.clear();
              usernameController.clear();
              passwordController.clear();
              showCustomDialog(
                context,
                "Registration Failed",
                "Please try again.",
                "OK",
              );
            },
          ),
        ],
      ),
    );
  }
}
