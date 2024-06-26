import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project_mobile_app/components/dialog.dart';
import 'package:project_mobile_app/screens/app/profile.dart';
import 'package:project_mobile_app/screens/authentication/camera.dart';
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
  File ? selectedImage;
  bool _isLoading = false; // Variable to track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Login"),
        ),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
      :Column(
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
              if (usernameController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                showCustomDialog(
                  context,
                  "Login Failed",
                  "Make sure to fill out everything.",
                  "OK",
                );
                return;
              }

              var sharedState = Provider.of<SharedState>(
                context,
                listen: false,
              ); 

              // Call the CameraScreen and wait for it to finish
              File ? selectedImage = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );

              if (selectedImage != null) {
                debugPrint("Image selected: ${selectedImage.path}");
                debugPrint("Sent username: ${usernameController.text}");
                int uploadResult = await uploadImage(selectedImage, usernameController.text);
                if (uploadResult == 1) {
                    //await sharedState.initializeMqtt(sharedState.backendIp, 'flutter_client');

                    final response = await sharedState.httpClient.post(
                      Uri.parse("http://${sharedState.backendIp}:3001/users/login"),
                      headers: {"Content-Type": "application/json; charset=UTF-8"},
                      body: jsonEncode({
                        "username": usernameController.text,
                        "password": passwordController.text,
                      }),
                    );

                    if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    if (data["_id"] != null) {
                      sharedState.email = data["email"];
                      sharedState.username = data["username"];
                      sharedState.id = data["_id"];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                      return;
                    }
                  }
                } else {
                  usernameController.clear();
                  passwordController.clear();
                  showCustomDialog(
                    context,
                    "Login Failed",
                    "Username or password was incorrect.",
                    "OK",
                  );
                }
              }  
            },
          ),
                    CustomButton(
            text: "Log in without Face-ID",
            onPressed: () async {
              if (usernameController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                showCustomDialog(
                  context,
                  "Login Failed",
                  "Make sure to fill out everything.",
                  "OK",
                );
                return;
              }

              var sharedState = Provider.of<SharedState>(
                context,
                listen: false,
              );

              setState(() {
                _isLoading = true;
              });    

              // Call the CameraScreen and wait for it to finish
              File ? selectedImage = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );

              final response = await sharedState.httpClient.post(
                Uri.parse("http://${sharedState.backendIp}:3001/users/login"),
                headers: {"Content-Type": "application/json; charset=UTF-8"},
                body: jsonEncode({
                  "username": usernameController.text,
                  "password": passwordController.text,
                }),
              );

              if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
                if (data["_id"] != null) {
                  sharedState.email = data["email"];
                  sharedState.username = data["username"];
                  sharedState.id = data["_id"];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                  return;
                }
              } else {
                  usernameController.clear();
                  passwordController.clear();
                  showCustomDialog(
                    context,
                    "Login Failed",
                    "Username or password was incorrect.",
                    "OK",
                  );
                }

              setState(() {
                _isLoading = false;
              });    
            },
          ),
        ],
      ),
    );
  }

  Future<int> uploadImage(File imageFile, String username) async {
    var sharedState = Provider.of<SharedState>(
      context,
      listen: false,
    );

    var request = http.MultipartRequest('POST', Uri.parse('http://${sharedState.backendIp}:5000/face-recognition/authenticate'));
    request.fields['user'] = username;
    debugPrint("[DEBUG] Username is $username");
    request.fields['purpose'] = 'auth';
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var result = jsonDecode(responseData);
      debugPrint(result['result']);
      if (result['result'] == '1') {
        return 1;
      } else {
        return 0;
      }
    } else if (response.statusCode == 400) {
      var responseData = await response.stream.bytesToString();
      var result = jsonDecode(responseData);
      debugPrint("ERROR: ${result['error']}");
      return 0;
    } else {
      debugPrint('Failed to upload image');
      return 0;
    }

  }
}