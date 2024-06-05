import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:geolocator/geolocator.dart';
import "package:http/http.dart" as http;
import 'package:latlong2/latlong.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_mobile_app/util/noise.dart';

class SharedState extends ChangeNotifier {
  final backendIp = "172.104.251.74";
  final httpClient = http.Client();
  MqttServerClient? _client;

  String? _email;
  String? _username;

  LatLng? _currentLocation;
  LatLng? _startingLocation;
  LatLng? _endLocation;

  Duration? _duration;
  double? _decibels;
  double? _maxDecibels;
  LatLng? _maxDecibelsLocation;

  final _recorder = FlutterSoundRecorder();
  final _recordingController = StreamController<Food>();
  bool get isRecording => _recorder.isRecording;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<RecordingDisposition>? _recordingStream;

  List<Noise> _noises = [];
  get noises => _noises;
  bool _gettingNoises = false;
  get gettingNoises => _gettingNoises;

  Future getNoises() async {
    _gettingNoises = true;
    final response = await httpClient.get(
      Uri.parse("http://$backendIp:3001/datas"),
    );

    // Change this eventually to fit new data format

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      for (var noise in data) {
        _noises.add(Noise(
          LatLng(
            noise["latitude"].toDouble(),
            noise["longitude"].toDouble(),
          ),
          noise["decibels"].toDouble(),
        ));
      }
      notifyListeners();
    }
    _gettingNoises = false;
  }

  SharedState() {
    Permission.microphone.request();
    _startPositionStream();
  }

  @override
  void dispose() async {
    stopRecording();
    _positionStream?.cancel();
    await endSession();
    super.dispose();
  }

  Future endSession() async {
    await httpClient.post(Uri.parse("http://$backendIp:3001/users/logout"));
    httpClient.close();
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
    // May need to move this function
    while (currentLocation == null) {}
    _startingLocation = currentLocation;

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
        // Check for drastic spike and stop recodring
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

    // Change data formating (also change to frontend)
    String? dataString = await dataToString(maxDecibelsLocation, maxDecibels);
    if (dataString != null) {
      sendData("noise/update", dataString);
    }

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

  // Modify this to include radius
  Future<String?> dataToString(LatLng? position, double? decibels) async {
    if (position != null && decibels != null) {
      return '{"latitude":${position.latitude},"longitude":${position.longitude},"decibels":${decibels.toString()}}';
    }

    return null;
  }

  // Initialize MQTT client
  Future<void> initializeMqtt(String server, String clientId) async {
    _client = MqttServerClient(server, clientId);
    _client!.logging(on: true);
    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.onSubscribed = _onSubscribed;
    _client!.onSubscribeFail = _onSubscribeFail;
    _client!.onUnsubscribed = _onUnsubscribed;
    _client!.pongCallback = _pong;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
    } catch (e) {
      debugPrint('Exception: $e');
      disconnect();
    }
  }

  void disconnect() {
    _client?.disconnect();
  }

  void _onConnected() {
    debugPrint('Connected');
  }

  void _onDisconnected() {
    debugPrint('Disconnected');
  }

  void _onSubscribed(String topic) {
    debugPrint('Subscribed to $topic');
  }

  void _onSubscribeFail(String topic) {
    debugPrint('Failed to subscribe $topic');
  }

  void _onUnsubscribed(String? topic) {
    debugPrint('Unsubscribed from $topic');
  }

  void _pong() {
    debugPrint('Ping response client callback invoked');
  }

  // Method to send data to a topic
  void sendData(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}
