import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// NOTE: latlong2 is no longer needed here as location is handled by gmaps.
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../models/animal_sighting_model.dart';
import '../models/animal_data.dart'; // <<< NEW IMPORT: Needed for imagePath and color
import '../services/map_service.dart';

class SightingDetailModal extends StatelessWidget {
  final AnimalSightingModel sighting;

  const SightingDetailModal({super.key, required this.sighting});

  @override
  Widget build(BuildContext context) {
    // Get the AnimalData to access the custom image and color
    final animalData = AnimalData.getAnimalData(sighting.animalType);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sighting.animalType.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: animalData.color, // Use animal color for title
                ),
              ),
              // CRITICAL FIX: Replaced Icon with custom Image.asset
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: animalData.color.withOpacity(0.1),
                ),
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  animalData.imagePath, // Use the custom image path
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          _buildInfoRow(
            context,
            Icons.access_time,
            'Reported At:',
            DateFormat('hh:mm a, MMM d').format(sighting.timestamp),
          ),
          _buildInfoRow(
            context,
            Icons.person,
            'Reported By:',
            sighting.reporterName,
          ),
          if (sighting.note != null && sighting.note!.isNotEmpty)
            _buildInfoRow(context, Icons.notes, 'Note:', sighting.note!),
          _buildInfoRow(
            context,
            Icons.healing,
            'Injured:',
            sighting.isInjured ? 'Yes' : 'No',
            valueColor: sighting.isInjured
                ? Theme.of(context).colorScheme.error
                : null,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Convert the model's latlong2.LatLng to gmaps.LatLng for the map service
                final gmaps.LatLng destination = gmaps.LatLng(
                  sighting.location.latitude,
                  sighting.location.longitude,
                );
                MapService().launchDirections(destination: destination);
              },
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    animalData.color, // Use animal color for the button
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
