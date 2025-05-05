import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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

  List<Map<String, dynamic>> hospitals = [];
  final String googleApiKey =
      "AIzaSyCgB0H3PXjukpvtmS5fIhf4kLZFr3jl5KU"; // Replace with your Google API Key

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation(); // Fetch user's current location on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text("Veerangana Maps",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        ),
        backgroundColor: Colors.purple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Map Section
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Stack(
              children: [
                GoogleMap(
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  markers: markers,
                  polylines: polylines, // Add polylines to the map
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: myCurrentLocation,
                    zoom: 12,
                  ),
                ),
                // Legend for pin colors
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        LegendItem(
                            color: Colors.blue, label: "Police Stations"),
                        LegendItem(color: Colors.red, label: "Hospitals"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Buttons to show paths
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _showPathToNearestPlace("police");
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Show Police Path",
                  style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _showPathToNearestPlace("hospital");
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    "Show Hospital Path",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Nearby Places Section
          Expanded(
            child: ListView(
              children: [
                _buildPlaceSection(
                    "Nearby Police Stations", policeStations, Colors.blue),
                _buildPlaceSection("Nearby Hospitals", hospitals, Colors.red),
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
      await _fetchDirections(myCurrentLocation, nearestStation);
    } else if (type == "hospital" && hospitals.isNotEmpty) {
      final LatLng nearestHospital = LatLng(
        hospitals[0]['latitude'],
        hospitals[0]['longitude'],
      );
      await _fetchDirections(myCurrentLocation, nearestHospital);
    }
  }

  Future<void> _fetchDirections(LatLng origin, LatLng destination) async {
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
            color: Colors.blue,
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
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
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

    // Fetch police stations
    await _fetchPlacesByType(
        location, "police", policeStations, BitmapDescriptor.hueBlue);

    // Fetch hospitals
    await _fetchPlacesByType(
        location, "hospital", hospitals, BitmapDescriptor.hueRed);
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
            });

            // Add marker for the place if markerColor is provided
            if (markerColor != null) {
              markers.add(Marker(
                markerId: MarkerId(place['name']),
                position: placeLocation,
                infoWindow: InfoWindow(title: place['name']),
                icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
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
      String title, List<Map<String, dynamic>> places, Color color) {
    return places.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: color, // Dynamically set the icon color
                      ),
                      title: Text(
                        place['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          "Distance: ${place['distance'].toStringAsFixed(2)} km"),
                      onTap: () {
                        // Move the map to the selected place
                        googleMapController
                            .animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target:
                                LatLng(place['latitude'], place['longitude']),
                            zoom: 15,
                          ),
                        ));
                      },
                    ),
                  );
                },
              ),
            ],
          );
  }

  // Calculate distance between two coordinates
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
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
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
