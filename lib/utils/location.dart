import 'package:geolocator/geolocator.dart';

Future<Position> getPosition() async {
  bool enabled = await Geolocator.isLocationServiceEnabled();
  if (!enabled) {
    print("Location services are disabled.");
    return Future.error("Location services are disabled.");
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permission was denied");
      return Future.error("Location permission was denied");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("Location permissions are permanently denied, we cannot request permissions.");
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}
