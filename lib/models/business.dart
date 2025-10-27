import 'package:cloud_firestore/cloud_firestore.dart';

class Business {
  final String uid;
  final String email;
  final String businessName;
  final String businessDescription;
  final String businessImageUrl;
  final double pricePerSafari;
  final String driverImageUrl;
  final double safariDurationHours;
  final String locationInfo;
  final String role;
  final bool isOpen;
  final String parkId; // Connects the driver to a specific park/category
  final String businessType; // 'park' or 'other_business'

  Business({
    required this.uid,
    required this.email,
    required this.businessName,
    required this.businessDescription,
    required this.businessImageUrl,
    required this.pricePerSafari,
    required this.driverImageUrl,
    required this.safariDurationHours,
    required this.locationInfo,
    required this.role,
    required this.isOpen,
    required this.parkId,
    required this.businessType,
  });

  // Factory constructor to create a Business object from a Firestore DocumentSnapshot
  factory Business.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data not available.");
    }
    return Business(
      uid: doc.id,
      email: data['email'] ?? '',
      businessName: data['business_name'] ?? 'Untitled Business',
      businessDescription:
          data['business_description'] ?? 'No description provided.',
      businessImageUrl:
          data['business_image_url'] ?? 'https://via.placeholder.com/150',
      pricePerSafari: (data['price_per_safari'] as num?)?.toDouble() ?? 0.0,
      driverImageUrl:
          data['driver_image_url'] ?? 'https://via.placeholder.com/150',
      safariDurationHours:
          (data['safari_duration_hours'] as num?)?.toDouble() ?? 2.0,
      locationInfo: data['location_info'] ?? 'Unknown Location',
      role: data['role'] ?? 'business_user',
      isOpen: data['is_open'] ?? false,
      parkId: data['park_id'] ?? '',
      businessType: data['business_type'] ?? 'park',
    );
  }

  // Convert Business object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'business_name': businessName,
      'business_description': businessDescription,
      'business_image_url': businessImageUrl,
      'price_per_safari': pricePerSafari,
      'driver_image_url': driverImageUrl,
      'safari_duration_hours': safariDurationHours,
      'location_info': locationInfo,
      'role': role,
      'is_open': isOpen,
      'park_id': parkId,
      'business_type': businessType,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
