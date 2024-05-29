import 'package:flutter/material.dart';
import 'package:project_mobile_app/components/app_bar.dart';
import 'package:project_mobile_app/state.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var sharedState = Provider.of<SharedState>(context);

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MainAppBar(title: 'Profile'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text("E-mail"),
                    subtitle: Text(sharedState.email ?? "Unknown"),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Username"),
                    subtitle: Text(sharedState.username ?? "Unknown"),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: sharedState.isRecording
                  ? sharedState.stopRecording
                  : sharedState.startRecording,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: Icon(
                sharedState.isRecording ? Icons.stop : Icons.mic,
                size: 80,
              ),
            ),
          ),
          Expanded(child: Container()),
          Text(
            """
            Duration: ${sharedState.duration}ms
            Decibels: ${sharedState.decibels}
            Max decibels: ${sharedState.maxDecibels ?? 0}
            """
                .replaceAll(RegExp(r"^\s+", multiLine: true), ""),
          ),
        ],
      ),
    );
  }
}
