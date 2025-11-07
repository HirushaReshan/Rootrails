import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  // Launches Google Maps with directions from current location to a destination
  Future<void> launchDirections({required LatLng destination}) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}&travelmode=driving';

    final Uri url = Uri.parse(googleMapsUrl);
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  // Launches Google Maps to a specific location
  Future<void> launchMapToLocation({
    required LatLng location,
    String? label,
  }) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}${label != null ? '($label)' : ''}';

    final Uri url = Uri.parse(googleMapsUrl);
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
