import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class SharedState extends ChangeNotifier {
  String? _username;
  String? _email;
  Duration? _duration;
  double? _decibels;
  double? _maxDecibels;
  LatLng? _maxDecibelsLocation;
  LatLng? _currentLocation;

  final _recorder = FlutterSoundRecorder();
  final _recordingController = StreamController<Food>();
  bool get isRecording => _recorder.isRecording;

  SharedState() {
    Permission.microphone.request();
  }

  Future startRecording() async {
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(
      const Duration(milliseconds: 100),
    );

    _recorder.onProgress?.listen((snapshot) {
      _duration = snapshot.duration;
      _decibels = snapshot.decibels!;

      if (decibels! > (maxDecibels ?? 0)) {
        _maxDecibels = decibels;
        _maxDecibelsLocation = currentLocation;
      }
      notifyListeners();
    });

    await _recorder.startRecorder(
      toStream: _recordingController.sink,
      codec: Codec.pcm16,
    );
    notifyListeners();
  }

  Future stopRecording() async {
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    notifyListeners();
  }

  String? get username => _username;
  set username(String? username) {
    _username = username;
    notifyListeners();
  }

  String? get email => _email;
  set email(String? email) {
    _email = email;
    notifyListeners();
  }

  Duration? get duration => _duration;
  double? get decibels => _decibels;
  double? get maxDecibels => _maxDecibels;
  LatLng? get maxDecibelsLocation => _maxDecibelsLocation;

  LatLng? get currentLocation => _currentLocation;
  set currentLocation(LatLng? currentLocation) {
    _currentLocation = currentLocation;
    notifyListeners();
  }
}
