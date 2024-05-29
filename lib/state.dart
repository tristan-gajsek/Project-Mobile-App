import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class SharedState extends ChangeNotifier {
  String? _username;
  String? _email;
  LatLng? _currentLocation;
  double? _maxDecibels;
  LatLng? _maxDecibelsLocation;

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

  LatLng? get currentLocation => _currentLocation;
  set currentLocation(LatLng? currentLocation) {
    _currentLocation = currentLocation;
    notifyListeners();
  }

  double? get maxDecibels => _maxDecibels;
  set maxDecibels(double? maxDecibels) {
    _maxDecibels = maxDecibels;
    notifyListeners();
  }

  LatLng? get maxDecibelsLocation => _maxDecibelsLocation;
  set maxDecibelsLocation(LatLng? maxDecibelsLocation) {
    _maxDecibelsLocation = maxDecibelsLocation;
    notifyListeners();
  }
}
