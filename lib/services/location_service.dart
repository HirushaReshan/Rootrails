import 'dart:async'; // Required for TimeoutException
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class LocationService {
  // Define a sensible default location (Only used as a fallback label, not returned on error anymore)
  static const gmaps.LatLng DEFAULT_LOCATION = gmaps.LatLng(
    7.8731,
    80.7718,
  ); // Example: Sri Lanka Center (same as map default)

  Future<gmaps.LatLng?> getCurrentLocation() async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        // 💡 FIX: Return null instead of DEFAULT_LOCATION on error
        return null;
      }

      // 2. Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          print('Location permission denied or denied forever.');
          // 💡 FIX: Return null instead of DEFAULT_LOCATION on denial
          return null;
        }
      }

      // Handle permanently denied permissions explicitly before fetching position
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
        // 💡 FIX: Return null instead of DEFAULT_LOCATION on permanent denial
        return null;
      }

      // 3. Get the actual position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Return the real location
      return gmaps.LatLng(position.latitude, position.longitude);
    } on TimeoutException {
      // Handle cases where the device is slow to respond
      print('Location request timed out. Could not get location.');
      return null; // 💡 FIX: Return null on timeout
    } catch (e) {
      // Catch any general errors (this often catches PC testing issues)
      print(
        'General location error ($e). Assuming environment issue and returning null.',
      );
      return null; // 💡 FIX: Return null on general error
    }
  }
}
