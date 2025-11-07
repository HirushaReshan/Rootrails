import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/park.dart';
import '../../models/animal_sighting_model.dart';
import '../../models/animal_data.dart'; // Import AnimalData

class OsmMapViewer extends StatefulWidget {
  final Park? selectedPark;
  final List<AnimalSightingModel> activeSightings;
  final LatLng? currentLocation;
  final Function(AnimalSightingModel)? onSightingTap;

  const OsmMapViewer({
    super.key,
    this.selectedPark,
    required this.activeSightings,
    this.currentLocation,
    this.onSightingTap,
  });

  @override
  State<OsmMapViewer> createState() => _OsmMapViewerState();
}

class _OsmMapViewerState extends State<OsmMapViewer> {
  final MapController _mapController = MapController();

  List<Marker> _buildSightingMarkers() {
    final sightingMarkers = widget.activeSightings.map((sighting) {
      final animalData = AnimalData.getAnimalData(sighting.animalType);
      final isInjured = sighting.isInjured;

      final markerColor = animalData.color;

      return Marker(
        // Adjusted width/height for image display
        width: 50.0,
        height: 50.0,
        point: sighting.location,
        child: GestureDetector(
          onTap: () {
            widget.onSightingTap?.call(sighting);
          },
          // Custom Image Widget Implementation
          child: Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                // Red border for injured, otherwise use the animal's color
                color: isInjured ? Colors.red.shade900 : markerColor,
                width: isInjured ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
              ],
            ),
            // Using Image.asset with the path from AnimalData
            child: Image.asset(animalData.imagePath, fit: BoxFit.contain),
          ),
        ),
      );
    }).toList();

    // 2. Marker for current user location
    final userMarker = widget.currentLocation != null
        ? [
            Marker(
              width: 80.0,
              height: 80.0,
              point: widget.currentLocation!,
              child: const Icon(
                Icons.my_location,
                color: Colors.blue,
                size: 40.0,
              ),
            ),
          ]
        : <Marker>[];

    return [...sightingMarkers, ...userMarker];
  }

  @override
  void didUpdateWidget(covariant OsmMapViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPark != oldWidget.selectedPark &&
        widget.selectedPark != null) {
      final centerLatLng = LatLng(
        widget.selectedPark!.center.latitude,
        widget.selectedPark!.center.longitude,
      );
      _mapController.move(centerLatLng, widget.selectedPark!.zoom);
    }
    if (widget.currentLocation != oldWidget.currentLocation &&
        widget.currentLocation != null) {
      _mapController.move(widget.currentLocation!, _mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    const defaultCenter = LatLng(7.8731, 80.7718);
    const defaultZoom = 8.0;

    final initialCenter = widget.selectedPark != null
        ? LatLng(
            widget.selectedPark!.center.latitude,
            widget.selectedPark!.center.longitude,
          )
        : defaultCenter;
    final initialZoom = widget.selectedPark?.zoom ?? defaultZoom;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        maxZoom: 18.0,
        minZoom: 3.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.yourcompany.rootrails',
        ),
        MarkerLayer(markers: _buildSightingMarkers()),
      ],
    );
  }
}
