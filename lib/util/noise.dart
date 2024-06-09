import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Noise {
  final LatLng location;
  final double decibels;
  final double radius;
  final Color color;

  Noise(this.location, this.decibels, this.radius, this.color);
}
