import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/location_service.dart';
import '../widgets/custom_bottom_nav.dart';
import 'map_screen.dart';
import 'contacts.dart';
import 'details.dart';
import 'package:vibration/vibration.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final LocationService _locationService = LocationService();
  String? userPhone; // Initialize LocationService
  @override
  void initState() {
    super.initState();

    // Start background location updates
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
                builder: (context) => const EmergencyContactScreen(
                      userPhone: '',
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

  // Widget buildGridButton(String label, String assetPath, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Card(
  //       elevation: 4,
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Image.asset(assetPath, height: 100),
  //           const SizedBox(height: 8),
  //           Text(label, textAlign: TextAlign.center),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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

  Widget buildGridButton(String label, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        elevation: 4,
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
              // Image.asset(assetPath, height: 100, width: 100, fit: BoxFit.cover),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
            // buildGridButton("Panic Mode", "assets/download.png", () {}),
            buildGridButton("Panic Mode", "assets/download.png", () async {
              // Vibrate the phone
              if (await Vibration.hasVibrator() ?? false) {
                Vibration.vibrate(duration: 1000); // 1 second
              }
            }),

            // Play beep sound
//   final player = AssetsAudioPlayer();
//   player.open(
//     Audio("assets/sounds/beep.mp3"),
//     autoStart: true,
//   );
// }),

            // buildGridButton("Police Contact", "assets/download (1).png", () {}),
            buildGridButton("Police Contact", "assets/download (1).png", () {
              // Call police emergency number (100)
              _makePhoneCall('100'); 
            }),
            buildGridButton("SOS", "assets/download (2).png", () {}),
            buildGridButton("Live Tracking", "assets/download (3).png", () {}),
            buildGridButton(
                "Voice Recording", "assets/download (4).png", () {}),
            buildGridButton(
                "Video Recording", "assets/download (5).png", () {}),
            buildGridButton(
                "Emergency Contacts", "assets/download (6).png", () {}),
            buildGridButton("Logout", "assets/hack.jpeg", () {}),
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
