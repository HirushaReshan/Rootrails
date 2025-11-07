import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import for LatLng

class Park {
  final String id;
  final String name;
  final String imageUrl;
  final String openTime;
  final double rating;
  final bool isOpenNow;
  final String location; // For the map link / location query

  // --- NEW FIELDS FOR MAP FUNCTIONALITY ---
  final LatLng center; // Center coordinate of the park for map
  final double zoom; // Default zoom level for this park
  // ----------------------------------------

  Park({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.openTime,
    required this.rating,
    required this.isOpenNow,
    required this.location,
    // Add new fields to constructor
    required this.center,
    required this.zoom,
  });

  factory Park.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Park data not available.");
    }

    // Safely extract GeoPoint and convert to LatLng
    GeoPoint geoPoint = data['center'] ?? const GeoPoint(0, 0);

    return Park(
      id: doc.id,
      name: data['name'] ?? 'Unknown Park',
      imageUrl: data['image_url'] ?? 'https://via.placeholder.com/300',
      openTime: data['open_time'] ?? '9:00 AM - 5:00 PM',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      isOpenNow: data['is_open_now'] ?? true,
      location: data['location_query'] ?? 'Africa',

      // Map fields from Firestore
      center: LatLng(geoPoint.latitude, geoPoint.longitude),
      zoom: (data['zoom'] as num?)?.toDouble() ?? 12.0,
    );
  }
}
