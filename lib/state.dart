import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

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
  String? _id;

  LatLng? _currentLocation;

  // Sešlovi variabli
  LatLng? _startingLocation;
  LatLng? _endLocation;
  LatLng? _center;
  double _decibelSum = 0;
  double _counter = 0;
  double? _avgDecibels;
  double? _radius;
  double? _range; // 0 = <=50 (Green), 1 = 51 - 80 (Yellow), 2 = 80< (Red)

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

      // Sešlov method: Check for drastic spike and restart recodring
      // Possible issues: Might not execute in time (needs simplification)
      _decibelSum += decibels!;
      _counter += 1;
      
      // After about 1 min of recording it starts comparing average to the predicted range
      // If average exceeds range or current range has been recording for about 30 mins it will execute the code
      if ((isOutOfRange(_decibelSum / _counter) && _counter >= 600) || _counter >= 18000) {
        _avgDecibels = _decibelSum / _counter;
        _endLocation = currentLocation;

        // Calculate distance
        _center = LatLng((_startingLocation!.latitude + _endLocation!.latitude) / 2, 
                        (_startingLocation!.longitude + _endLocation!.longitude) / 2);

        // Triangulate radius
        double latDist = (_startingLocation!.latitude - _endLocation!.latitude).abs();
        double longDist = (_startingLocation!.longitude - _endLocation!.longitude).abs();
        _radius = sqrt((latDist*latDist) + (longDist*longDist)) / 2;

        /* Needs to be done withou await
        String? dataString = await dataToString(center, avgDecibels, radius);
        if (dataString != null) {
          sendData("noise/update", dataString);
        }
        */

        // Reset values
        _decibelSum = 0;
        _counter = 0;
        range = _avgDecibels;
        _startingLocation = _endLocation;
        _endLocation = null;
        _center = null;
        _avgDecibels = null;
      }

      /* Tristanov method:
      if (decibels! > (maxDecibels ?? 0)) {
        _maxDecibels = decibels;
        _maxDecibelsLocation = currentLocation;
      }
      */

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

    // New way: Need to add radius
    String? dataString = await dataToString(center, avgDecibels, radius);
    if (dataString != null) {
      sendData("noise/update", dataString);
    }

    /* Old way:
    String? dataString = await dataToString(maxDecibelsLocation, maxDecibels);
    if (dataString != null) {
      sendData("noise/update", dataString);
    }
    */

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

  String? get id => _id;
  set id(String? id) {
    _id = id;
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

  double? get range => _range;
  set range(double? decibels) {
    if (decibels != null) {
      if (decibels <= 50) {
        _range = 0; // Green
      } else if (50 < decibels && decibels <= 80) {
        _range = 1; // Yellow
      } else {
        _range = 2; // Red
      }
    }
  }

  double? get avgDecibels => _avgDecibels;
  LatLng? get center => _center;
  double? get radius => _radius;

  // New way: Need to add radius
  Future<String?> dataToString(LatLng? position, double? decibels, double? radius) async {
    if (position != null && decibels != null && radius != null) {
      return '{"latitude":${position.latitude},"longitude":${position.longitude},"decibels":${decibels.toString()},"radius":${radius.toString()}}';
    }

    return null;
  }

  /* Old way:
  Future<String?> dataToString(LatLng? position, double? decibels) async {
    if (position != null && decibels != null) {
      return '{"latitude":${position.latitude},"longitude":${position.longitude},"decibels":${decibels.toString()}}';
    }

    return null;
  }
  */

  // Might need to simplify
  bool isOutOfRange(double decibels) {
    // Current ranges:
    //  < 50dB = Green
    // 51dB - 80dB = Yellow
    // 81db < = Red
    if (range == 0) {
      if (decibels <= 50) {
        return true;
      } else {
        return false;
      }
    } else if (range == 2) {
      if (50 < decibels && decibels <= 80) {
        return true;
      } else {
        return false;
      }
    } else if (range == 3) {
      if (80 < decibels) {
        return true;
      } else {
        return false;
      }
    }

    return false;
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
