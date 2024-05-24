import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_mobile_app/components/app_bar.dart';
import 'package:project_mobile_app/utils/location.dart' as location;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getPosition();
  }

  Future<void> _getPosition() async {
    Position position = await location.getPosition();
    setState(() {
      mapController.move(
        LatLng(position.latitude, position.longitude),
        mapController.camera.zoom,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MainAppBar(title: 'Map'),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: const MapOptions(),
        children: [
          openStreetMapTileLayer,
        ],
      ),
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      userAgentPackageName: "dev.fleaflet.flutter_map.example",
    );
