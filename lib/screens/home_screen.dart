import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart'; // adjust path based on your structure

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        Navigator.pushNamed(context, '/map');
        break;
      case 2:
        Navigator.pushNamed(context, '/contacts');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
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
        title: const Text("Women Safety App"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            buildGridButton("Panic Mode", "assets/hack.jpeg", () {}),
            buildGridButton("Police Contact", "assets/hack.jpeg", () {}),
            buildGridButton("SOS", "assets/hack.jpeg", () {}),//sos
            buildGridButton("Live Tracking", "assets/hack.jpeg", () {}),//tracking
            buildGridButton("Voice Recording", "assets/hack.jpeg", () {}),//voice
            buildGridButton("Video Recording", "assets/hack.jpeg", () {}),//video
            buildGridButton("Emergency Contacts", "assets/hack.jpeg", () {}),//emergency
            buildGridButton("Logout", "assets/hack.jpeg", () {}),//logout
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
