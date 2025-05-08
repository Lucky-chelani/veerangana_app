import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veerangana/screens/start_screen.dart'; // Login or start screen
import 'package:veerangana/screens/home_screen.dart';
import 'package:veerangana/widgets/custom_bottom_nav.dart';  // Replace with your main screen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return const BottomNavBar(initialIndex: 0,); // User is logged in
        } else {
          return const StartScreen(); // User is not logged in
        }
      },
    );
  }
}
