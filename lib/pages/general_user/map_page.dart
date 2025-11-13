import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // IMPORTANT: Use this LatLng for the map and state
import '../../services/location_service.dart';
import '../../services/sighting_service.dart';
import '../../services/map_service.dart';
import '../../models/park.dart';
import '../../models/animal_sighting_model.dart';
import '../../widgets/report_sighting_modal.dart';
import '../../widgets/sighting_detail_modal.dart';
// Import the new OSM viewer widget
import 'osm_map_viewer.dart';
// Alias the Google Maps LatLng type for compatibility with SightingService/Models
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

// Define the custom colors used for consistency (if not globally available)
const Color kPrimaryGreen = Color(0xFF4C7D4D);
const Color kOrangeAccent = Color(0xFFFFA500);

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Use latlong2.LatLng for state internally, as it matches flutter_map
  LatLng? _currentLocation;

  List<AnimalSightingModel> _activeSightings = [];

  Park? _selectedPark;
  List<Park> _availableParks = [];
  bool _isLoadingParks = true;

  final LocationService _locationService = LocationService();
  final SightingService _sightingService = SightingService();
  final MapService _mapService = MapService();

  @override
  void initState() {
    super.initState();
    _loadParks();
    // 💡 FIX 1: Start fetching location immediately when the page loads
    _getCurrentLocation();
  }

  void _loadParks() async {
    _sightingService.getParks().listen(
      (parks) {
        setState(() {
          _availableParks = parks;
          _isLoadingParks = false;

          if (_availableParks.isNotEmpty && _selectedPark == null) {
            _selectedPark = _availableParks.first;
            _goToPark(_selectedPark!, isInitialLoad: true);
          }
        });
      },
      onError: (error) {
        debugPrint("Error loading parks: $error");
        setState(() {
          _isLoadingParks = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load parks: $error')));
      },
    );
  }

  void _listenToActiveSightings() {
    if (_selectedPark != null) {
      _sightingService
          .getActiveSightings(_selectedPark!.id)
          .listen(
            (sightings) {
              setState(() {
                _activeSightings = sightings;
              });
            },
            onError: (error) {
              debugPrint("Error listening to sightings: $error");
            },
          );
    } else {
      setState(() {
        _activeSightings = []; // Clear sightings if no park is selected
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // locationService returns a gmaps.LatLng? type (now returns null on failure)
      final location = await _locationService.getCurrentLocation();

      if (location != null) {
        // Convert the location service's gmaps.LatLng to latlong2.LatLng
        setState(() {
          _currentLocation = LatLng(location.latitude, location.longitude);
        });
      } else {
        // If location is null (due to permission or service error), inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location unavailable. Check permissions and GPS.'),
            duration: Duration(seconds: 4),
          ),
        );
        setState(() {
          _currentLocation = null; // Ensure the state reflects no location
        });
      }
    } catch (e) {
      debugPrint("Error getting current location: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    }
  }

  void _goToPark(Park park, {bool isInitialLoad = false}) {
    setState(() {
      _selectedPark = park;
      _activeSightings = []; // Clear old sightings while new ones load
    });

    // Restart sighting listener for the new park
    _listenToActiveSightings();

    // 💡 FIX 2: Ensure location is being fetched/retried when switching parks
    if (_currentLocation == null) {
      _getCurrentLocation();
    }
  }

  void _showReportSightingModal() {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fetching current location... please wait.'),
        ),
      );
      _getCurrentLocation();
      return;
    }

    if (_selectedPark == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a park first.')),
      );
      return;
    }

    // CRITICAL: Convert latlong2.LatLng state back to gmaps.LatLng for SightingService
    final gmaps.LatLng locationToReport = gmaps.LatLng(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ReportSightingModal(
          onReportConfirmed: (animalType, note, isInjured) async {
            // 'animalType' here is the AnimalType enum
            if (_selectedPark != null) {
              final success = await _sightingService.reportSighting(
                parkId: _selectedPark!.id,
                // FIX: Pass the AnimalType enum directly.
                animalType: animalType,
                location: locationToReport,
                note: note,
                isInjured: isInjured,
              );
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sighting reported successfully!'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to report sighting.')),
                );
              }
            }
          },
        );
      },
    );
  }

  void _showSightingDetails(AnimalSightingModel sighting) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SightingDetailModal(sighting: sighting);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Passing latlong2.LatLng to OsmMapViewer, as it is based on flutter_map.
    final LatLng? currentLocForMap = _currentLocation;

    final mapWidget = OsmMapViewer(
      selectedPark: _selectedPark,
      activeSightings: _activeSightings,
      currentLocation: currentLocForMap,
      onSightingTap: _showSightingDetails,
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Viewer (The full canvas area)
          Positioned.fill(child: mapWidget),

          // --- 2. Park Selection Dropdown ---
          Positioned(
            top: 10.0,
            left: 10.0,
            right: 10.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: _isLoadingParks
                    ? const Center(child: LinearProgressIndicator())
                    : DropdownButton<Park>(
                        value: _selectedPark,
                        hint: const Text('Select a Park'),
                        onChanged: (Park? newValue) {
                          if (newValue != null) {
                            _goToPark(newValue);
                          }
                        },
                        items: _availableParks.map<DropdownMenuItem<Park>>((
                          Park park,
                        ) {
                          return DropdownMenuItem<Park>(
                            value: park,
                            child: Text(park.name),
                          );
                        }).toList(),
                      ),
              ),
            ),
          ),

          // --- 3. Get Current Location Button (Bottom Left) ---
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: FloatingActionButton.extended(
              heroTag: 'myLocationBtn',
              onPressed: _getCurrentLocation,
              label: const Text('My Location'),
              icon: const Icon(Icons.my_location),
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
            ),
          ),

          // --- 4. Report Sighting Button (Bottom Right) ---
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton.extended(
              heroTag: 'reportSightingBtn',
              // Disable if no park selected or no location known
              onPressed: _selectedPark == null || _currentLocation == null
                  ? null
                  : _showReportSightingModal,
              label: const Text('Report Sighting'),
              // Using 'Icons.campaign' as requested
              icon: const Icon(Icons.campaign),
              backgroundColor: _selectedPark == null || _currentLocation == null
                  ? Colors
                        .grey // Disabled color
                  : kOrangeAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
