import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_mobile_app/components/app_bar.dart';
import 'package:project_mobile_app/components/buttons.dart';
import 'package:project_mobile_app/state.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  bool _foundFirstLocation = false;

  @override
  void initState() {
    super.initState();
    _startPositionStream();
    var sharedState = Provider.of<SharedState>(context);

    if (sharedState.currentLocation != null) {
      _mapController.move(
        sharedState.currentLocation!,
        _mapController.camera.zoom,
      );
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  void _startPositionStream() {
    _positionStream =
        Geolocator.getPositionStream().listen((Position position) {
      var sharedState = Provider.of<SharedState>(context, listen: false);

      setState(() {
        sharedState.currentLocation = LatLng(
          position.latitude,
          position.longitude,
        );

        if (!_foundFirstLocation) {
          _mapController.move(
            sharedState.currentLocation!,
            _mapController.camera.zoom,
          );
          _foundFirstLocation = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var sharedState = Provider.of<SharedState>(context);

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MainAppBar(title: 'Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: mapOptions,
              children: [
                openStreetMapTileLayer,
                circleLayer,
                markerLayer(sharedState.currentLocation)
              ],
            ),
          ),
          WideButton(
            text: "Center Map",
            onPressed: sharedState.currentLocation == null
                ? null
                : () => _mapController.move(
                      sharedState.currentLocation!,
                      _mapController.camera.zoom,
                    ),
          ),
          // Text("Latitude: ${sharedState.currentLocation?.latitude}"),
          // Text("Longitude: ${sharedState.currentLocation?.longitude}"),
        ],
      ),
    );
  }
}

MapOptions get mapOptions => const MapOptions(
      maxZoom: 16,
      minZoom: 4,
    );

TileLayer get openStreetMapTileLayer => TileLayer(
      retinaMode: true,
      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      userAgentPackageName: "dev.fleaflet.flutter_map.example",
    );

MarkerLayer markerLayer(LatLng? currentLocation) {
  if (currentLocation == null) {
    return const MarkerLayer(markers: []);
  }

  return MarkerLayer(
    markers: [
      Marker(
        point: currentLocation,
        rotate: true,
        alignment: Alignment.topCenter,
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40,
        ),
      )
    ],
  );
}

CircleLayer get circleLayer => CircleLayer(
      circles: [
        CircleMarker(
          point: const LatLng(46.1512, 14.9955),
          radius: 25,
          color: Colors.red.withOpacity(0.5),
        ),
      ],
    );
