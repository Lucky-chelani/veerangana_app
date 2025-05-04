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
    try {
      // Update the user's location in the locations collection
      await _firestore.collection('locations').doc(userPhone).set({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Also update location in the user document
      await _firestore.collection('users').doc(userPhone).update({
        'lastLocation': {
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': FieldValue.serverTimestamp(),
        }
      });
      
      print('Location updated successfully for user: $userPhone');
    } catch (e) {
      print('Error saving location to Firebase: $e');
      throw e;
    }
  }
  
  // Get current location with permission handling
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        return Future.error("Location permission denied.");
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  
  // Track user location in real-time
  Future<void> startLocationTracking(String userPhone) async {
    // Request permissions first
    await initializeLocationTracking(userPhone);
    
    // Listen for location changes
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) async {
      try {
        await saveLocationToFirebase(
          userPhone,
          position.latitude,
          position.longitude,
        );
      } catch (e) {
        print('Error in location tracking: $e');
      }
    });
  }
}