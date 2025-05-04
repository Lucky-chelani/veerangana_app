import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initializes location tracking when user logs in or signs up
  Future<void> initializeLocationTracking(String userPhone) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return Future.error("Location permission denied.");
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await saveLocationToFirebase(userPhone, position.latitude, position.longitude);
  }

  // Saves location data to Firestore
  Future<void> saveLocationToFirebase(String userPhone, double latitude, double longitude) async {
    await _firestore.collection('locations').doc(userPhone).set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Starts a background task to update location every 30 minutes
  Future<void> startBackgroundLocationUpdates(String userPhone) async {
    Timer.periodic(const Duration(minutes: 30), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await saveLocationToFirebase(userPhone, position.latitude, position.longitude);
      } catch (e) {
        print('Failed to update location: $e');
      }
    });
  }
}
