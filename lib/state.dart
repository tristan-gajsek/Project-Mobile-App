import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SharedState extends ChangeNotifier {
  MqttServerClient? _client;

  String? _email;
  String? _username;

  LatLng? _currentLocation;

  Duration? _duration;
  double? _decibels;
  double? _maxDecibels;
  LatLng? _maxDecibelsLocation;

  final _recorder = FlutterSoundRecorder();
  final _recordingController = StreamController<Food>();
  bool get isRecording => _recorder.isRecording;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<RecordingDisposition>? _recordingStream;

  SharedState() {
    Permission.microphone.request();
    _startPositionStream();
  }

  @override
  void dispose() {
    stopRecording();
    _positionStream?.cancel();
    super.dispose();
  }

  void _startPositionStream() {
    _positionStream = Geolocator.getPositionStream().listen((Position pos) {
      _currentLocation = LatLng(
        pos.latitude,
        pos.longitude,
      );
      notifyListeners();
    });
  }

  void startRecording() async {
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(
      const Duration(milliseconds: 100),
    );

    _recordingStream = _recorder.onProgress?.listen((snapshot) {
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

  void stopRecording() async {
    _recordingStream?.cancel();
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

    // Initialize MQTT client
  Future<void> initializeMqtt(String server, String clientId) async {
    _client = MqttServerClient(server, clientId);
    _client!.logging(on: true);
    _client!.onConnected = _onConnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
    } catch (e) {
      print('Exception: $e');
      disconnect();
    }
  }

  void disconnect() {
    _client?.disconnect();
  }

  void _onConnected() {
    debugPrint('Connected');
  }
}
