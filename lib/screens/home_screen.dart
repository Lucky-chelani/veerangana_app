import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/location_service.dart';
import '../widgets/custom_bottom_nav.dart';
import 'map_screen.dart';
import 'contacts.dart';
import 'details.dart';
import 'package:vibration/vibration.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sms/flutter_sms.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final LocationService _locationService = LocationService();
  String? userPhone;
  bool isSendingSOS = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  void initState() {
    super.initState();
    _fetchUserPhoneAndTrackLocation();
  }

  Future<void> _fetchUserPhoneAndTrackLocation() async {
    final prefs = await SharedPreferences.getInstance();
    userPhone = prefs.getString('userPhone');

    if (userPhone != null) {
      try {
        await _locationService.initializeLocationTracking(userPhone!);
      } catch (e) {
        print('Error initializing location tracking: $e');
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MapScreen()));
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EmergencyContactScreen(
                      userPhone: userPhone ?? '',
                    )));
        break;
      case 3:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DetailsScreen(
                      phone: '',
                    )));
        break;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res == false) {
      // If unable to make the call
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not make the phone call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Get current location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable the GPS'),
          backgroundColor: Colors.red,
        ),
      );
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied'),
            backgroundColor: Colors.red,
          ),
        );
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied'),
          backgroundColor: Colors.red,
        ),
      );
      return Future.error('Location permissions are permanently denied');
    }

    // When permissions are granted, get the current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
  }

  // Get address from coordinates
  Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      if (placemarks.isEmpty) {
        return "Unknown location";
      }
      
      Placemark place = placemarks[0];
      return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      print("Error getting address: $e");
      return "Error getting address";
    }
  }

  // Get emergency contacts from Firestore
  Future<List<Map<String, String>>> _getEmergencyContacts() async {
    if (userPhone == null || userPhone!.isEmpty) {
      throw Exception('User phone number not available');
    }
    
    try {
      final userDoc = await _firestore.collection('users').doc(userPhone).get();
      
      if (!userDoc.exists || !userDoc.data()!.containsKey('emergencyContacts')) {
        return [];
      }
      
      final emergencyContactsData = List<Map<String, dynamic>>.from(
          userDoc.data()!['emergencyContacts'] ?? []);
      
      // Convert to the format we need
      return emergencyContactsData.map((contact) {
        return {
          'name': contact['name'] as String,
          'phone': contact['phone'] as String,
        };
      }).toList();
    } catch (e) {
      print("Error fetching emergency contacts: $e");
      throw Exception('Failed to fetch emergency contacts');
    }
  }

  // Send SOS
  Future<void> _sendSOS() async {
    if (isSendingSOS) return;
    
    setState(() {
      isSendingSOS = true;
    });

    try {
      // Vibrate for feedback
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000]);
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sending SOS messages...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );

      // Get emergency contacts
      List<Map<String, String>> emergencyContacts = await _getEmergencyContacts();
      
      if (emergencyContacts.isEmpty) {
        throw Exception("No emergency contacts found. Please add emergency contacts first.");
      }

      // Get current location
      Position position = await _getCurrentLocation();
      String address = await _getAddressFromCoordinates(position);
      
      // Store SOS event in Firestore for tracking
      await _firestore.collection('sos_events').add({
        'user': userPhone,
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'status': 'initiated',
      });
      
      // Update user's location in Firestore
      await _locationService.saveLocationToFirebase(
        userPhone!, 
        position.latitude, 
        position.longitude
      );
      
      // Create SOS message
      String message = """
EMERGENCY SOS ALERT!

I need help! This is an emergency message from ${userPhone ?? 'a user'}.

My current location:
$address

Google Maps Link:
https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}

This is an automated emergency message from the Women Safety App.
      """;

      // Send SMS to all emergency contacts
      List<String> recipients = emergencyContacts.map((contact) => contact['phone']!).toList();
      
      // Log all recipients for debugging
      print("Sending SOS to: $recipients");
      
      String result = await sendSMS(
        message: message,
        recipients: recipients,
        sendDirect: true,
      ).catchError((onError) {
        throw Exception("Failed to send SMS: $onError");
      });

      print("SMS Result: $result");
      
      // Update SOS event status
      await _firestore.collection('sos_events')
          .where('user', isEqualTo: userPhone)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({
            'status': 'sent',
          });
        }
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS messages sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      print("Error sending SOS: $e");
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send SOS: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSendingSOS = false;
      });
    }
  }

  Widget buildGridButton(String label, String assetPath, VoidCallback onTap) {
    // Special styling for SOS button
    bool isSOSButton = label == "SOS";
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSOSButton 
            ? const BorderSide(color: Colors.red, width: 2.0) 
            : BorderSide.none,
        ),
        color: isSOSButton ? const Color(0xFFFFEBEE) : Colors.white,
        elevation: isSOSButton ? 6 : 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  assetPath,
                  height: 110,
                  width: 110,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSOSButton ? Colors.red : Colors.black87,
                ),
              ),
              if (isSOSButton)
                const Text(
                  "Send emergency alert",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEEFF),
      //appbar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          elevation: 6,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFE040FB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),
          centerTitle: true,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Women Safety App",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Your safety, our priority",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Add navigation logic
            },
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            buildGridButton("Panic Mode", "assets/download.png", () async {
              // Vibrate the phone
              if (await Vibration.hasVibrator() ?? false) {
                Vibration.vibrate(duration: 1000); // 1 second
              }
            }),
            buildGridButton("Police Contact", "assets/download (1).png", () {
              // Call police emergency number (100)
              _makePhoneCall('100'); 
            }),
            buildGridButton("SOS", "assets/download (2).png", _sendSOS),
            buildGridButton("Live Tracking", "assets/download (3).png", () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MapScreen()));
            }),
            buildGridButton(
                "Voice Recording", "assets/download (4).png", () {}),
            buildGridButton(
                "Video Recording", "assets/download (5).png", () {}),
            buildGridButton(
                "Emergency Contacts", "assets/download (6).png", () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => EmergencyContactScreen(
                  //       userPhone: userPhone ?? '',
                  //     ),
                  //   ),
                  // );
                }),
            buildGridButton("Logout", "assets/hack.jpeg", () async {
              // Clear user session
              // final prefs = await SharedPreferences.getInstance();
              // await prefs.clear();
              
              // Navigate to login screen
              // Replace this with your actual login screen navigation
              //Navigator.of(context).popUntil((route) => route.isFirst);
            }),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}