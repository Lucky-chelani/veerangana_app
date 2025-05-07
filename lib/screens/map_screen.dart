import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:veerangana/ui/colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng myCurrentLocation = const LatLng(0.0, 0.0); // Default location (0,0)
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  List<Map<String, dynamic>> policeStations = [];
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};
  bool isMapExpanded = false;

  List<Map<String, dynamic>> hospitals = [];
  final String googleApiKey =
      "AIzaSyCgB0H3PXjukpvtmS5fIhf4kLZFr3jl5KU"; // Replace with your Google API Key

  @override
  void initState() {
    super.initState();
_initializeMap();// Fetch user's current location on initialization
  }
    BitmapDescriptor? policePin; // Custom pin for police
  BitmapDescriptor? hospitalPin; 

  Future<void> _initializeMap() async {
  await _loadCustomPins();
  await _fetchCurrentLocation();
}

    Future<void> _loadCustomPins() async {
    policePin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(12, 12)),
      'assets/policepin.png', // Add your custom police pin image to assets
    );
    hospitalPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(12, 12)),
      'assets/hospitalpin.png', // Add your custom hospital pin image to assets
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Veerangana Maps",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.rosePink,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Map Section
         GestureDetector(
  onTap: () {
    setState(() {
      isMapExpanded = !isMapExpanded;
    });
  },
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: isMapExpanded ? 450 : 200,
    width: double.infinity,
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: AppColors.deepBurgundy.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: !isMapExpanded, // Disable interactions when collapsed
            child: GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              markers: markers,
              polylines: polylines,
              onMapCreated: (GoogleMapController controller) {
                googleMapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: myCurrentLocation,
                zoom: 12,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepBurgundy.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  LegendItem(
                    color: AppColors.raspberry,
                    label: "Police Stations",
                  ),
                  SizedBox(height: 4),
                  LegendItem(
                    color: AppColors.rosePink,
                    label: "Hospitals",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),


          
          // Path Buttons Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepBurgundy.withValues(alpha:0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _showPathToNearestPlace("police");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.raspberry,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.local_police, size: 20),
                    label: const Text(
                      "Police Path",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _showPathToNearestPlace("hospital");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rosePink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.local_hospital, size: 20),
                    label: const Text(
                      "Hospital Path",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Nearby Places Section - Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.rosePink.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Nearby Emergency Services",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBurgundy,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Places List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              children: [
                _buildPlaceSection(
                  "Nearby Police Stations",
                  policeStations,
                  AppColors.raspberry,
                  Icons.local_police,
                ),
                _buildPlaceSection(
                  "Nearby Hospitals",
                  hospitals,
                  AppColors.rosePink,
                  Icons.local_hospital,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPathToNearestPlace(String type) async {
    if (type == "police" && policeStations.isNotEmpty) {
      final LatLng nearestStation = LatLng(
        policeStations[0]['latitude'],
        policeStations[0]['longitude'],
      );
      await _fetchDirections(myCurrentLocation, nearestStation, type: type);
    } else if (type == "hospital" && hospitals.isNotEmpty) {
      final LatLng nearestHospital = LatLng(
        hospitals[0]['latitude'],
        hospitals[0]['longitude'],
      );
      await _fetchDirections(myCurrentLocation, nearestHospital, type: type);
    }
  }

  Future<void> _fetchDirections(LatLng origin, LatLng destination, {String type = "police"}) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List steps = data['routes'][0]['legs'][0]['steps'];

        setState(() {
          polylineCoordinates.clear();
          for (var step in steps) {
            final LatLng startLocation = LatLng(
              step['start_location']['lat'],
              step['start_location']['lng'],
            );
            final LatLng endLocation = LatLng(
              step['end_location']['lat'],
              step['end_location']['lng'],
            );
            polylineCoordinates.add(startLocation);
            polylineCoordinates.add(endLocation);
          }

          // Add the polyline to the map
          polylines.add(Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: type == "hospital" ? AppColors.rosePink : AppColors.raspberry, // Match path color based on type
            width: 5,
          ));
        });
      } else {
        print("Failed to fetch directions: ${response.body}");
      }
    } catch (e) {
      print("Error fetching directions: $e");
    }
  }

  // Fetch user's current location
  Future<void> _fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        myCurrentLocation = currentLocation;
        markers.add(Marker(
          markerId: const MarkerId("user_location"),
          position: currentLocation,
          infoWindow: const InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ));
      });

      // Move the map camera to the user's current location
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation,
            zoom: 12, // Adjust zoom level as needed
          ),
        ),
      );

      // Fetch nearby places
      await _fetchNearbyPlaces(currentLocation);
    } catch (e) {
      print("Error fetching current location: $e");
    }
  }

  // Fetch nearby places using Google Places API
  Future<void> _fetchNearbyPlaces(LatLng location) async {
    const int radius = 5000; // 5km radius

    // Fetch police stations with raspberry color
    await _fetchPlacesByType(
        location, "police", policeStations, BitmapDescriptor.hueRose);

    // Fetch hospitals with rose color
    await _fetchPlacesByType(
        location, "hospital", hospitals, BitmapDescriptor.hueRose);
  }

  // Fetch places by type
  Future<void> _fetchPlacesByType(
    LatLng location,
    String type,
    List<Map<String, dynamic>> placesList,
    double? markerColor,
  ) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=5000&type=$type&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        setState(() {
          placesList.clear();
          for (var place in results) {
            final LatLng placeLocation = LatLng(
              place['geometry']['location']['lat'],
              place['geometry']['location']['lng'],
            );
            final double distance = _calculateDistance(
              location.latitude,
              location.longitude,
              placeLocation.latitude,
              placeLocation.longitude,
            );

            placesList.add({
              'name': place['name'],
              'latitude': placeLocation.latitude,
              'longitude': placeLocation.longitude,
              'distance': distance,
              'vicinity': place['vicinity'] ?? 'Address not available',
            });

            // Add marker for the place if markerColor is provided
BitmapDescriptor? customIcon;
if (type == "police") {
  customIcon = policePin;
} else if (type == "hospital") {
  customIcon = hospitalPin;
}

if (customIcon != null) {
  markers.add(Marker(
    markerId: MarkerId(place['name']),
    position: placeLocation,
    infoWindow: InfoWindow(title: place['name']),
    icon: customIcon,
  ));
}
          }

          // Sort the places by distance and keep only the nearest 5
          placesList.sort((a, b) => a['distance'].compareTo(b['distance']));
          if (placesList.length > 5) {
            placesList.removeRange(5, placesList.length);
          }
        });
      } else {
        print("Failed to fetch $type: ${response.body}");
      }
    } catch (e) {
      print("Error fetching $type: $e");
    }
  }

  // Build a section for a specific type of place
  Widget _buildPlaceSection(
      String title, List<Map<String, dynamic>> places, Color color, IconData icon) {
    return places.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: color.withValues(alpha:0.2),
                        width: 1,
                      ),
                    ),
                    elevation: 2,
                    shadowColor: color.withValues(alpha:0.1),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha:0.15),
                        child: Icon(
                          icon,
                          color: color,
                        ),
                      ),
                      title: Text(
                        place['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBurgundy,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "Distance: ${place['distance'].toStringAsFixed(2)} km",
                            style: TextStyle(
                              color: AppColors.deepBurgundy.withValues(alpha:0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            place['vicinity'] ?? 'Address not available',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.deepBurgundy.withValues(alpha:0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.directions),
                        color: color,
                        onPressed: () {
                          // Move the map to the selected place
                          googleMapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(place['latitude'], place['longitude']),
                                zoom: 15,
                              ),
                            ),
                          );
                          
                          // Show route to this place
                          _fetchDirections(
                            myCurrentLocation,
                            LatLng(place['latitude'], place['longitude']),
                            type: title.toLowerCase().contains("hospital") ? "hospital" : "police",
                          );
                        },
                      ),
                      onTap: () {
                        // Move the map to the selected place
                        googleMapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(place['latitude'], place['longitude']),
                              zoom: 15,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
  }

  // Calculate distance between two coordinates
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

// Legend widget for pin colors
class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.deepBurgundy,
          ),
        ),
      ],
    );
  }
}