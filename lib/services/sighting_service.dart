import 'package:cloud_firestore/cloud_firestore.dart';
// Alias Google Maps LatLng as gmaps for clarity, as this service accepts it
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
// Import latlong2's LatLng because the AnimalSightingModel requires it
import 'package:latlong2/latlong.dart' as latlong2;
import '../models/animal_sighting_model.dart';
import '../models/park.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SightingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- NEW: Configuration Fetcher ---

  /// Fetches the expiry duration (in minutes) from Firestore configuration.
  /// If fetching fails or the value is missing, it defaults to 240 minutes (4 hours).
  Future<int> _getExpiryDurationInMinutes() async {
    const int defaultDuration = 240; // 4 hours in minutes
    try {
      // Fetch the document from 'settings' collection, document 'sighting_config'
      final doc = await _firestore
          .collection('settings')
          .doc('sighting_config')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Read the field 'activeDurationMinutes'
        final duration = data['activeDurationMinutes'] as int?;

        // Return fetched duration or the safe default
        return duration ?? defaultDuration;
      }
      // Default if the document does not exist
      return defaultDuration;
    } catch (e) {
      print('Error fetching sighting expiry duration from Firestore: $e');
      // Fallback in case of error
      return defaultDuration;
    }
  }

  // --- UPDATED: Active Sightings Stream ---

  /// Stream of active sightings for a given park, filtered by a duration fetched from Firestore.
  Stream<List<AnimalSightingModel>> getActiveSightings(
    String parkId, {
    // Kept for backward compatibility, though configuration is now dynamic
    Duration? expiryDuration,
  }) async* {
    // Changed to async* to allow awaiting the config fetch

    // 1. Determine expiry duration (use local override or fetch from Firestore)
    final Duration actualExpiryDuration;

    if (expiryDuration != null) {
      actualExpiryDuration = expiryDuration; // Use local override if provided
    } else {
      final durationMinutes =
          await _getExpiryDurationInMinutes(); // Fetch from Firestore
      actualExpiryDuration = Duration(minutes: durationMinutes);
    }

    // 2. Calculate the cutoff time based on the determined duration
    final cutoffTime = DateTime.now().subtract(actualExpiryDuration);

    // 3. Yield the stream of sightings filtered by the calculated cutoff time
    yield* _firestore
        .collection('animalSightings')
        .where('parkId', isEqualTo: parkId)
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffTime),
        ) // Use Timestamp for comparison
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AnimalSightingModel.fromFirestore(doc))
              .toList(),
        );
  }

  // --- Other Methods (No Changes) ---

  // Fetch all parks
  Stream<List<Park>> getParks() {
    return _firestore
        .collection('parks')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Park.fromFirestore(doc))
              .toList(), // Use Park.fromFirestore
        );
  }

  // Report a new animal sighting
  Future<bool> reportSighting({
    required String parkId,
    required AnimalType animalType,
    // FIX: Accept the gmaps.LatLng type that MapPage is sending.
    required gmaps.LatLng location,
    String? note,
    bool isInjured = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('User not logged in to report sighting.');
        return false;
      }

      // Fetch reporter's name from Firestore 'users' collection
      String reporterName = 'Anonymous';
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        // Assuming your 'users' document has a 'name' field
        reporterName = userDoc.data()!['name'] ?? user.email ?? 'Anonymous';
      }

      // FIX: Convert the incoming gmaps.LatLng to latlong2.LatLng for the model
      final latlong2.LatLng modelLocation = latlong2.LatLng(
        location.latitude,
        location.longitude,
      );

      final sighting = AnimalSightingModel(
        id: _firestore
            .collection('animalSightings')
            .doc()
            .id, // Generate a new ID
        parkId: parkId,
        reporterId: user.uid,
        reporterName: reporterName,
        animalType: animalType,
        // Use the converted latlong2.LatLng
        location: modelLocation,
        note: note,
        isInjured: isInjured,
        timestamp: DateTime.now(),
      );

      // The model's toMap() function handles converting latlong2.LatLng back to GeoPoint.
      await _firestore.collection('animalSightings').add(sighting.toMap());
      return true;
    } catch (e) {
      print('Error reporting sighting: $e');
      return false;
    }
  }

  // Get a single sighting for details
  Future<AnimalSightingModel?> getSightingDetails(String sightingId) async {
    try {
      final doc = await _firestore
          .collection('animalSightings')
          .doc(sightingId)
          .get();
      if (doc.exists) {
        return AnimalSightingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching sighting details: $e');
      return null;
    }
  }
}
