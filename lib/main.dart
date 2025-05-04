import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:veerangana/firebase_options.dart';
import 'package:veerangana/location_service.dart';
import 'package:veerangana/screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

  final locationService = LocationService();

  // ⚠️ TODO: Replace this with the actual phone number from your login/OTP flow
  String userPhone = "9876543210";
  //String userPhone = await SharedPreferences.getInstance().then((prefs) => prefs.getString('userPhone') ?? '');


  // Initialize location tracking and start background updates
  await locationService.initializeLocationTracking(userPhone);
  locationService.startBackgroundLocationUpdates(userPhone);

  runApp(const WomenSafetyApp());
}

class WomenSafetyApp extends StatelessWidget {
  const WomenSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Women Safety App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Roboto',
      ),
      home: const StartScreen(), // You can conditionally redirect to HomeScreen if user is already logged in
    );
  }
}
