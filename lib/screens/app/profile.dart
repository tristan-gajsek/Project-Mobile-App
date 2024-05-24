import 'package:flutter/material.dart';
import 'package:project_mobile_app/components/app_bar.dart';
import 'package:project_mobile_app/globals.dart' as globals;

class ProfileScreen extends StatefulWidget {
  final String email;
  final String username;

  const ProfileScreen({super.key, required this.email, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MainAppBar(title: 'Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(globals.padding),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text("E-mail"),
              subtitle: Text(widget.email),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Username"),
              subtitle: Text(widget.username),
            ),
          ),
        ],
      ),
    );
  }
}
