import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'map_screen.dart';
import 'contacts.dart';
import 'details.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen(locationUrl: "https://maps.google.com/?q=23.456,77.123",)));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyContactScreen(userPhone: '',)));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailsScreen(phone: '',)));
        break;
    }
  }

  Widget buildGridButton(String label, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(assetPath, height: 50),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEEFF),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              "Women Safety App",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              "Your safety, our priority",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            buildGridButton("Panic Mode", "assets/download.png", () {}),
            buildGridButton("Police Contact", "assets/download (1).png", () {}),
            buildGridButton("SOS", "assets/download (2).png", () {}),
            buildGridButton("Live Tracking", "assets/download (3).png", () {}),
            buildGridButton("Voice Recording", "assets/download (4).png", () {}),
            buildGridButton("Video Recording", "assets/download (5).png", () {}),
            buildGridButton("Emergency Contacts", "assets/download (6).png", () {}),
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
