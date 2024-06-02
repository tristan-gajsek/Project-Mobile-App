import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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

  @override
  Widget build(BuildContext context) {
    var sharedState = Provider.of<SharedState>(context);
    if (sharedState.noises.isEmpty && !sharedState.gettingNoises) {
      sharedState.getNoises();
    }

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
              options: mapOptions(sharedState.currentLocation),
              children: [
                openStreetMapTileLayer,
                circleLayer(sharedState),
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
        ],
      ),
    );
  }
}

MapOptions mapOptions([LatLng? initialCenter]) => MapOptions(
      initialCenter: initialCenter ?? const LatLng(50.5, 30.51),
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

CircleLayer circleLayer(SharedState sharedState) {
  List<CircleMarker> circles = [];
  for (var noise in sharedState.noises) {
    circles.add(CircleMarker(
      point: noise.location,
      radius: noise.decibels,
      color: Colors.red.withOpacity(0.5),
    ));
  }
  return CircleLayer(circles: circles);
}
