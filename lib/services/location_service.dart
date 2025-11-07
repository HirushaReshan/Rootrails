import 'dart:async'; // Required for TimeoutException
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class LocationService {
  // Define a sensible default location (e.g., the center of a major park/city)
  static const gmaps.LatLng DEFAULT_LOCATION = 
      gmaps.LatLng(7.8731, 80.7718); // Example: Sri Lanka Center (same as map default)

  Future<gmaps.LatLng?> getCurrentLocation() async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Services are disabled (common on desktop/simulator). Use fallback.
        print('Location services are disabled. Using default location.');
        return DEFAULT_LOCATION;
      }

      // 2. Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          // Permissions denied. Use fallback.
          print('Location permission denied. Using default location.');
          return DEFAULT_LOCATION;
        }
      }
      
      // Handle permanently denied permissions explicitly before fetching position
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied. Using default location.');
        return DEFAULT_LOCATION;
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
      print('Location request timed out. Using default location.');
      return DEFAULT_LOCATION;
    } catch (e) {
      // Catch any general errors (this is the main fix for PC testing)
      print('General location error ($e). Assuming desktop and using default location.');
      return DEFAULT_LOCATION;
    }
  }
}