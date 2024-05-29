import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_mobile_app/components/app_bar.dart';
import 'package:project_mobile_app/globals.dart' as globals;
import 'package:project_mobile_app/state.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String email;
  final String username;

  const ProfileScreen({super.key, required this.email, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _recorder = FlutterSoundRecorder();
  final _recordingController = StreamController<Food>();
  double? maxDecibels;
  LatLng? maxDecibelsLocation;

  @override
  void initState() {
    super.initState();
    Permission.microphone.request();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future startRecording() async {
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(
      const Duration(milliseconds: 100),
    );

    await _recorder.startRecorder(
      toStream: _recordingController.sink,
      codec: Codec.pcm16,
    );
    setState(() {});
  }

  Future stopRecording() async {
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    setState(() {});
  }

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
          ),
          Center(
            child: ElevatedButton(
              onPressed: _recorder.isRecording ? stopRecording : startRecording,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: Icon(
                _recorder.isRecording ? Icons.stop : Icons.mic,
                size: 80,
              ),
            ),
          ),
          Expanded(child: Container()),
          StreamBuilder<RecordingDisposition>(
            stream: _recorder.onProgress,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text("");
              }

              var duration = snapshot.data!.duration;
              var decibels = snapshot.data!.decibels!;
              if (decibels > (sharedState.maxDecibels ?? 0)) {
                sharedState.maxDecibels = decibels;
              }

              return Text(
                """
                Duration: ${duration.inMilliseconds}ms
                Decibels: $decibels
                Max decibels: ${sharedState.maxDecibels ?? 0}
                """
                    .replaceAll(RegExp(r"^\s+", multiLine: true), ""),
              );
            },
          ),
        ],
      ),
    );
  }
}
