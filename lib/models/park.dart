import 'package:cloud_firestore/cloud_firestore.dart';

class Park {
  final String id;
  final String name;
  final String imageUrl;
  final String openTime;
  final double rating;
  final bool isOpenNow;
  final String location; // For the map link

  Park({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.openTime,
    required this.rating,
    required this.isOpenNow,
    required this.location,
  });

  factory Park.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Park data not available.");
    }

    // This model now correctly reads from the 'parks' collection
    return Park(
      id: doc.id,
      name: data['name'] ?? 'Unknown Park',
      imageUrl: data['image_url'] ?? 'https://via.placeholder.com/300',
      openTime: data['open_time'] ?? '9:00 AM - 5:00 PM',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      isOpenNow: data['is_open_now'] ?? true, // Simplified status
      location: data['location_query'] ?? 'Africa', // Query for Google Maps
    );
  }
}
