import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_mobile_app/components/app_bar.dart';
import 'package:project_mobile_app/components/buttons.dart';
import 'package:project_mobile_app/utils/location.dart' as location;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapController = MapController();
  LatLng? currentPosition;
  bool isFetchingPosition = false;

  @override
  void initState() {
    super.initState();
    _getPosition();
  }

  Future<void> _getPosition() async {
    setState(() {
      isFetchingPosition = true;
    });

    Position position = await location.getPosition();

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
      mapController.move(
        currentPosition!,
        mapController.camera.zoom,
      );
      isFetchingPosition = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MainAppBar(title: 'Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: mapOptions,
              children: [
                openStreetMapTileLayer,
                circleLayer,
                markerLayer(currentPosition)
              ],
            ),
          ),
          WideButton(
            text:
                isFetchingPosition ? "Fetching position..." : "Reset Position",
            onPressed: isFetchingPosition ? null : _getPosition,
          ),
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

MarkerLayer markerLayer(LatLng? currentPosition) {
  if (currentPosition == null) {
    return const MarkerLayer(markers: []);
  }

  return MarkerLayer(
    markers: [
      Marker(
        point: currentPosition,
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
