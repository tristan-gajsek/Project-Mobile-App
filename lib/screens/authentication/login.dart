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
  File? selectedImage;
  String? userId; // Variable to store the user's ID
  var result;

  Future<void> login() async {

    var sharedState = Provider.of<SharedState>(
      context,
      listen: false,
    );

    final response = await http.post(
      Uri.parse("http://${sharedState.backendIp}:3001/users/login"),
      body: {
        'username': usernameController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["_id"] != null) {
        sharedState.email = data["email"];
        sharedState.username = data["username"];
        sharedState.id = data["_id"];
        userId = data['_id']; // Set local var userId for use in uploadImage
      }

    } else {
      showCustomDialog(context, "Login failed.", "Please try again.", "OK");
    }
  }

  Future<void> uploadImage(File image) async {
    if (userId == null) {
      showCustomDialog(context, "Login failed.", "User ID not available.", "OK");
      return;
    }

    var sharedState = Provider.of<SharedState>(
      context,
      listen: false,
    );

    var request = http.MultipartRequest('POST', Uri.parse('http://${sharedState.backendIp}:5000/face-recognition/authenticate'));
    request.fields['user'] = userId!;
    debugPrint("USER ID: $userId");
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
              if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
                showCustomDialog(context, "Login failed.", "Please fill in both fields.", "OK");
                return;
              }

              await login();

              File ? selectedImage = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );

              if (selectedImage != null) {
                await uploadImage(selectedImage);
                //debugPrint("RESULT AT NAV PUSH: $result");
                if (result['result'] == "1")
                {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                }
                else
                {
                  showCustomDialog(context, "Face authentication failed.", "Please try again.", "OK");
                }
                }
            },
          ),
        ],
      ),
    );
  }
}