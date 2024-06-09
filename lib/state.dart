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
  double _subCounter = 0;
  double? _avgDecibels;
  double? _radius;
  double _range = 0; // 0 = <=45 (Green), 1 = 46 - 70 (Yellow), 2 = 70< (Red)

  final _lowerLim = 45;
  final _upperLim = 70;


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
        double noiseDecibels = noise["decibels"].toDouble();
        Color noiseColor = const Color.fromRGBO(255, 0, 0, 0.5);
        if (noiseDecibels <= _lowerLim) {
          noiseColor = const Color.fromRGBO(0, 255, 0, 0.5); // Green
        } else if (_lowerLim < noiseDecibels && noiseDecibels <= _upperLim) {
          noiseColor = const Color.fromRGBO(255, 255, 0, 0.5); // Yellow
        } 

        _noises.add(Noise(
          LatLng(
            noise["latitude"].toDouble(),
            noise["longitude"].toDouble(),
          ),
          noiseDecibels,
          noise["radius"].toDouble(),
          noiseColor,
        ));
      }
      notifyListeners();
    }
    _gettingNoises = false;
  }

  SharedState() {
    Permission.microphone.request();
    _startPositionStream();
    debugPrint('SharedState constructor: _client: $_client');
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
    // Reset values
    _decibelSum = 0;
    _counter = 0;
    _subCounter = 0;
    _endLocation = null;
    _center = null;
    _avgDecibels = null;

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
      if (decibels != null) {
        _decibelSum += decibels!;
        _counter += 1;
        _subCounter += 1;

        if (_counter >= 100 && _counter <= 105) {
          range = _avgDecibels;
        }

        // After about 30 sec of recording it starts comparing average to the predicted range
        // If average exceeds range or current range has been recording for about 15 mins it will execute the code
        if ((isOutOfRange(_decibelSum / _subCounter) && _counter >= 300) || _counter >= 9000) {
          configVariables();
        } else {
          _avgDecibels = _decibelSum / _subCounter;

          if (_subCounter >= 150) {
            _avgDecibels ??= _decibelSum / _subCounter;
            _subCounter = 1;
            _decibelSum = _avgDecibels!;
          }
        }

        /* Tristanov method:
        if (decibels! > (maxDecibels ?? 0)) {
          _maxDecibels = decibels;
          _maxDecibelsLocation = currentLocation;
        }
        */
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

    configVariables();
    _avgDecibels = null;

    /* Old way:
    String? dataString = await dataToString(maxDecibelsLocation, maxDecibels);
    if (dataString != null) {
      sendData("noise/updates", dataString);
    }
    */

    notifyListeners();
  }

  void configVariables() {
    //_avgDecibels = _decibelSum / _subCounter;
    _endLocation = currentLocation;

    // Calculate distance
    _center = LatLng((_startingLocation!.latitude + _endLocation!.latitude) / 2, 
                    (_startingLocation!.longitude + _endLocation!.longitude) / 2);

    // Triangulate radius
    double latDist = (_startingLocation!.latitude - _endLocation!.latitude).abs();
    double longDist = (_startingLocation!.longitude - _endLocation!.longitude).abs();
    _radius = sqrt((latDist*latDist) + (longDist*longDist)) / 2;

    _avgDecibels ??= (_decibelSum / _subCounter) - 1;
    String? dataString = dataToString(center, avgDecibels, radius, id);
    if (dataString != null) {
      sendData("noise/updates", dataString);
    }

    // Reset values
    _avgDecibels = _decibelSum / _subCounter;
    _decibelSum = 0;
    _counter = 0;
    _subCounter = 0;
    range = _avgDecibels;
    _startingLocation = _endLocation;
    _endLocation = null;
    _center = null;
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

  double get range => _range;
  set range(double? decibels) {
    if (decibels != null) {
      if (decibels <= _lowerLim) {
        _range = 0; // Green
      } else if (_lowerLim < decibels && decibels <= _upperLim) {
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
  String? dataToString(LatLng? position, double? decibels, double? radius, String? id) {
    if (position != null && decibels != null && radius != null && id != null) {
      return '{"latitude":${position.latitude},"longitude":${position.longitude},"decibels":${decibels.toString()},"radius":${radius.toString()}, "id":"$id"}';
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
    //  < 45dB = Green
    // 46dB - 70dB = Yellow
    // 71db < = Red
    if (range == 0) {
      if (decibels > _lowerLim) {
        return true;
      } else {
        return false;
      }
    } else if (range == 1) {
      if (_lowerLim >= decibels && decibels > _upperLim) {
        return true;
      } else {
        return false;
      }
    } else if (range == 2) {
      if (_upperLim >= decibels) {
        return true;
      } else {
        return false;
      }
    }

    return false;
  }

  // Initialize MQTT client
  Future<void> initializeMqtt(String server, String clientId) async {
    debugPrint('MQTT Client Initialization on server: $server');
    _client = MqttServerClient.withPort(server, clientId, 1883);
    //_client!.port = 8888;
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
        .withWillQos(MqttQos.atMostOnce);
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
    debugPrint('Publishing message $message');
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (_client != null) {
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } else {
      debugPrint('The client is null');
    }
  }
}
