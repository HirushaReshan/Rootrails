import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // IMPORTANT: Use this LatLng for consistency

// --- 1. Animal Type Enum ---
enum AnimalType { leopard, slothBear, elephant, deer, peacock, snakes, other }

// --- 2. Enum Extensions for Name and Icon Mapping ---
extension AnimalTypeExtension on AnimalType {
  String get name {
    switch (this) {
      case AnimalType.leopard:
        return 'Leopard';
      case AnimalType.slothBear:
        return 'Sloth Bear';
      case AnimalType.elephant:
        return 'Elephant';
      case AnimalType.deer:
        return 'Deer';
      case AnimalType.peacock:
        return 'Peacock';
      case AnimalType.snakes:
        return 'Snakes';
      case AnimalType.other:
        return 'Other';
    }
  }

  // NOTE: The 'icon' getter has been REMOVED as custom images are used via AnimalData.
}

// --- 3. Animal Sighting Model Class (No Change Needed) ---
class AnimalSightingModel {
  final String id;
  final String parkId;
  final String reporterId; // User ID who reported
  final String reporterName;
  final AnimalType animalType;
  final LatLng location; // latlong2.LatLng type
  final String? note;
  final bool isInjured;
  final DateTime timestamp;

  AnimalSightingModel({
    required this.id,
    required this.parkId,
    required this.reporterId,
    required this.reporterName,
    required this.animalType,
    required this.location,
    this.note,
    this.isInjured = false,
    required this.timestamp,
  });

  // Factory constructor to deserialize from Firestore DocumentSnapshot
  factory AnimalSightingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("AnimalSighting document data is null");
    }
    GeoPoint geoPoint = data['location'] ?? const GeoPoint(0, 0);

    // Find the correct enum value from the stored string
    final animalTypeString = data['animalType'] as String? ?? 'other';
    final parsedAnimalType = AnimalType.values.firstWhere(
      (e) => e.toString().split('.').last == animalTypeString,
      orElse: () => AnimalType.other,
    );

    return AnimalSightingModel(
      id: doc.id,
      parkId: data['parkId'] ?? '',
      reporterId: data['reporterId'] ?? '',
      reporterName: data['reporterName'] ?? 'Anonymous',
      animalType: parsedAnimalType,
      // Convert Firestore GeoPoint to latlong2.LatLng
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      note: data['note'],
      isInjured: data['isInjured'] ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Method to serialize to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'parkId': parkId,
      'reporterId': reporterId,
      'reporterName': reporterName,
      // Store the enum name as a string
      'animalType': animalType.toString().split('.').last,
      // Convert latlong2.LatLng to GeoPoint for Firestore
      'location': GeoPoint(location.latitude, location.longitude),
      'note': note,
      'isInjured': isInjured,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
