import 'package:flutter/material.dart';

const double padding = 10;

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
      appBar: AppBar(
        title: const Center(
          child: Text("Profile"),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(padding),
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
