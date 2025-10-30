import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String uid; // This is the Business User's UID
  final String parkId;
  final String businessName;
  final String driverImageUrl;
  final double rating;
  final double pricePerSafari;
  final double safariDurationHours;
  final bool isOpenNow;
  final String locationInfo;
  final String businessDescription; // Added for detail page

  Driver({
    required this.uid,
    required this.parkId,
    required this.businessName,
    required this.driverImageUrl,
    required this.rating,
    required this.pricePerSafari,
    required this.safariDurationHours,
    required this.isOpenNow,
    required this.locationInfo,
    required this.businessDescription,
  });

  // This factory builds a Driver object from a 'drivers' collection document
  factory Driver.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) throw Exception("Driver data not available.");

    return Driver(
      uid: doc.id,
      parkId: data['park_id'] ?? '',
      businessName: data['business_name'] ?? 'Unknown Driver',
      driverImageUrl:
          data['driver_image_url'] ?? 'https://via.placeholder.com/150',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      pricePerSafari: (data['price_per_safari'] as num?)?.toDouble() ?? 0.0,
      safariDurationHours:
          (data['safari_duration_hours'] as num?)?.toDouble() ?? 3.0,
      isOpenNow: data['is_open'] ?? false, // Reads the 'is_open' field
      locationInfo: data['location_info'] ?? 'Park entrance',
      businessDescription:
          data['business_description'] ?? 'No description available.',
    );
  }
}