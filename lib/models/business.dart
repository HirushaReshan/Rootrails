import 'package:cloud_firestore/cloud_firestore.dart';

class Business {
  final String uid;
  final String email;
  final String businessName;
  final String businessDescription;
  final String businessImageUrl; // Listing image
  final double pricePerSafari;
  final String driverImageUrl; // Driver's personal photo
  final double safariDurationHours;
  final String locationInfo;
  final String role;
  final bool isOpen;
  final String parkId; // ID of the park they are associated with
  final String businessType; // 'park' or 'other_business'
  final double rating;

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
    required this.rating,
  });

  // Factory constructor from a Firestore Document
  factory Business.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Business data not available.");
    }
    return Business(
      uid: doc.id,
      email: data['email'] ?? '',
      businessName: data['business_name'] ?? 'Untitled Business',
      businessDescription: data['business_description'] ?? 'No description.',
      businessImageUrl:
          data['business_image_url'] ?? 'https://via.placeholder.com/300',
      pricePerSafari: (data['price_per_safari'] as num?)?.toDouble() ?? 0.0,
      driverImageUrl:
          data['driver_image_url'] ?? 'https://via.placeholder.com/150',
      safariDurationHours:
          (data['safari_duration_hours'] as num?)?.toDouble() ?? 0.0,
      locationInfo: data['location_info'] ?? 'Unknown Location',
      role: data['role'] ?? 'business_user',
      isOpen: data['is_open'] ?? false,
      parkId: data['park_id'] ?? '',
      businessType: data['business_type'] ?? 'park',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  //Added THE copyWith METHOD TO FIX THE COMPILATION ERROR
  Business copyWith({
    String? uid,
    String? email,
    String? businessName,
    String? businessDescription,
    String? businessImageUrl,
    double? pricePerSafari,
    String? driverImageUrl,
    double? safariDurationHours,
    String? locationInfo,
    String? role,
    bool? isOpen,
    String? parkId,
    String? businessType,
    double? rating,
  }) {
    return Business(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      businessImageUrl: businessImageUrl ?? this.businessImageUrl,
      pricePerSafari: pricePerSafari ?? this.pricePerSafari,
      driverImageUrl: driverImageUrl ?? this.driverImageUrl,
      safariDurationHours: safariDurationHours ?? this.safariDurationHours,
      locationInfo: locationInfo ?? this.locationInfo,
      role: role ?? this.role,
      isOpen: isOpen ?? this.isOpen,
      parkId: parkId ?? this.parkId,
      businessType: businessType ?? this.businessType,
      rating: rating ?? this.rating,
    );
  }

  // Convert Business object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
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
      'rating': rating,
    };
  }
}
