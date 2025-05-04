import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng myCurrentLocation = const LatLng(0.0, 0.0); // Default location (0,0)
  late GoogleMapController googleMapController;
  Set<Marker> marker = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userPhone; // To store the user's phone number

  @override
  void initState() {
    super.initState();
    _fetchUserPhoneAndLocation(); // Fetch user phone and location on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        myLocationButtonEnabled: false,
        markers: marker,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: myCurrentLocation, // Use the fetched location as default
          zoom: 14,
        ),
      ),
    );
  }

  // Fetch user phone from SharedPreferences and then fetch location from Firestore
  Future<void> _fetchUserPhoneAndLocation() async {
    final prefs = await SharedPreferences.getInstance();
    userPhone = prefs.getString('userPhone'); // Retrieve the phone number

    if (userPhone != null) {
      await _fetchLocationFromFirestore(); // Fetch location if phone number exists
    } else {
      print("User phone number not found in SharedPreferences.");
    }
  }

  // Fetch location from Firestore and update the map
  Future<void> _fetchLocationFromFirestore() async {
    if (userPhone == null) {
      print("User phone number is null. Cannot fetch location.");
      return;
    }

    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('locations').doc(userPhone).get();

      if (snapshot.exists) {
        double latitude = snapshot['latitude'];
        double longitude = snapshot['longitude'];

        // Update the default location and map with the fetched location
        LatLng fetchedLocation = LatLng(latitude, longitude);
        setState(() {
          myCurrentLocation = fetchedLocation; // Update the default location
          marker.clear();
          marker.add(Marker(
            markerId: const MarkerId("Fetched Location"),
            position: fetchedLocation,
          ));
        });

        // Move the camera to the fetched location
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: fetchedLocation,
            zoom: 15,
          ),
        ));
      } else {
        print("No location data found for user.");
      }
    } catch (e) {
      print("Error fetching location from Firestore: $e");
    }
  }
}