import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/firebase_options.dart';
import 'package:veerangana/location_service.dart';
import 'package:veerangana/screens/powerButton.dart';
import 'package:veerangana/screens/start_screen.dart';
import 'package:veerangana/ui/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:veerangana/sakhi/gemini_service.dart';
import 'package:veerangana/sakhi/chat_provider.dart';
import 'package:veerangana/sakhi/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // print('hello1');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  // print('hello2');
  // await initializeService();
  // print('hello3');
  
  await _requestPermissions();
  
  runApp(const WomenSafetyApp());
}

Future<void> _requestPermissions() async {
  // List of permissions to request
  final permissions = [
    Permission.sms,
    Permission.location,
    Permission.locationAlways,
    Permission.phone,
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    //Permission.internet, // Added for Gemini API access
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

class WomenSafetyApp extends StatelessWidget {
  const WomenSafetyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide Gemini service for the chatbot
        Provider<GeminiService>(
          create: (_) => GeminiService(
            apiKey: AppConfig.geminiApiKey,
          ),
        ),
        // Provide chat functionality
        ChangeNotifierProxyProvider<GeminiService, ChatProvider>(
          create: (context) => ChatProvider(
            geminiService: Provider.of<GeminiService>(context, listen: false),
          ),
          update: (context, geminiService, previousChatProvider) =>
              previousChatProvider ?? ChatProvider(geminiService: geminiService),
        ),
        // Add other providers if needed
      ],
      child: MaterialApp(
        title: 'Veerangana - Women Safety App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        //fontFamily: 'Poppins',
        home: const StartScreen(), // You can add logic here to go to HomeScreen if user is already logged in
      ),
    );
  }
}