import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF8E24AA), // Deep purple
                    Color(0xFFBA68C8), // Medium purple
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Women Safety App",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Stay safe and connected",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            
            // Main features grid
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Panic Mode
                  FeatureCard(
                    title: "Panic Mode",
                    icon: _buildCustomIcon(
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "PANIC",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      // Add navigation or action for Panic Mode
                    },
                  ),
                  
                  // Police Contact
                  FeatureCard(
                    title: "Police Contact",
                    icon: _buildCustomIcon(
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.indigo[900],
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          "https://cdn-icons-png.flaticon.com/512/1048/1048370.png",
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () {
                      // Add navigation or action for Police Contact
                    },
                  ),
                  
                  // SOS
                  FeatureCard(
                    title: "SOS",
                    icon: _buildCustomIcon(
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "SOS",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              Icon(
                                Icons.radar,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      // Add navigation or action for SOS
                    },
                  ),
                  
                  // Live Tracking
                  FeatureCard(
                    title: "Live Tracking",
                    icon: _buildCustomIcon(
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              "https://cdn-icons-png.flaticon.com/512/854/854878.png",
                              color: Colors.white70,
                            ),
                            const Positioned(
                              right: 10,
                              top: 10,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                            const Positioned(
                              left: 15,
                              bottom: 8,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      // Add navigation or action for Live Tracking
                    },
                  ),
                  
                  // Voice Recording
                  FeatureCard(
                    title: "Voice Recording",
                    icon: _buildCustomIcon(
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              "https://cdn-icons-png.flaticon.com/512/3389/3389961.png",
                              color: Colors.cyan[300],
                            ),
                            const Positioned(
                              child: Icon(
                                Icons.mic,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      // Add navigation or action for Voice Recording
                    },
                  ),
                  
                  // Video Recording
                  FeatureCard(
                    title: "Video Recording",
                    icon: _buildCustomIcon(
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.blue,
                              size: 32,
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  "REC",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      // Add navigation or action for Video Recording
                    },
                  ),
                  
                  // Emergency Contacts
                  FeatureCard(
                    title: "Emergency Contacts",
                    icon: _buildCustomIcon(
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              "EMERGENCY",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmergencyContactScreen(
                            userPhone: "user_phone_placeholder", // Replace with actual user phone
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Logout
                  FeatureCard(
                    title: "Logout",
                    icon: _buildCustomIcon(
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Colors.red[300]!, Colors.red[700]!],
                            center: Alignment.center,
                            radius: 0.8,
                          ),
                          border: Border.all(color: Colors.grey[300]!, width: 3),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.power_settings_new,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      // Add logout functionality
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
            
            // Bottom navigation bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavBarItem(
                    context,
                    icon: Icons.home,
                    label: "Home",
                    isSelected: true,
                    onTap: () {},
                  ),
                  _buildNavBarItem(
                    context,
                    icon: Icons.contacts,
                    label: "Contacts",
                    onTap: () {
                      // Navigate to contacts
                    },
                  ),
                  _buildNavBarItem(
                    context,
                    icon: Icons.settings,
                    label: "Settings",
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomIcon(Widget icon) {
    return SizedBox(
      height: 70,
      width: 70,
      child: icon,
    );
  }

  Widget _buildNavBarItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE1BEE7) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF8E24AA) : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF8E24AA) : Colors.grey[600],
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                // Add logout logic here
                Navigator.of(context).pop();
                // Navigate to login screen
              },
            ),
          ],
        );
      },
    );
  }
}

// Feature card widget for each grid item
class FeatureCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E24AA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for EmergencyContactScreen to avoid errors
// Replace this with the actual import for your EmergencyContactScreen
class EmergencyContactScreen extends StatelessWidget {
  final String userPhone;
  
  const EmergencyContactScreen({super.key, required this.userPhone});
  
  @override
  Widget build(BuildContext context) {
    // This is just a placeholder. You should use your actual EmergencyContactScreen here.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Contacts"),
      ),
      body: const Center(
        child: Text("Emergency Contact Screen"),
      ),
    );
  }
}