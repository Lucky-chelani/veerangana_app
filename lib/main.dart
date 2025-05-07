import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/firebase_options.dart';
import 'package:veerangana/location_service.dart';
import 'package:veerangana/screens/powerButton.dart';
import 'package:veerangana/screens/start_screen.dart';
import 'package:veerangana/ui/app_theme.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 // print('hello1');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  //  print('hello2');
  // await initializeService();
   //  print('hello3');
 
  runApp(const WomenSafetyApp());
}

class WomenSafetyApp extends StatefulWidget {
  const WomenSafetyApp({super.key});

  @override
  State<WomenSafetyApp> createState() => _WomenSafetyAppState();
}

class _WomenSafetyAppState extends State<WomenSafetyApp> {
  Future<void> initState() async {
    
    super.initState();
       // _requestPermissions();
         await _requestPermissions();
  

  }
  Future<void> _requestPermissions() async {
  // List of permissions to request
  final permissions = [
    Permission.location,
    Permission.locationAlways,
    Permission.sms,
    Permission.phone,
    Permission.camera,
    Permission.microphone,
    Permission.storage,
  ];

  // Request each permission
  for (var permission in permissions) {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Handle permissions that are permanently denied
  if (await Permission.locationAlways.isPermanentlyDenied) {
    openAppSettings(); // Open app settings to manually enable permissions
  }
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Women Safety App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      //fontFamily: 'Poppins',
      home: const StartScreen(), // You can add logic here to go to HomeScreen if user is already logged in
    );
  }
}
