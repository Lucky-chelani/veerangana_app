import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:veerangana/firebase_options.dart';
import 'package:veerangana/screens/shakeDetctionInitializer.dart';
import 'package:veerangana/screens/start_screen.dart';
import 'package:veerangana/ui/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:veerangana/sakhi/gemini_service.dart';
import 'package:veerangana/sakhi/chat_provider.dart';
import 'package:veerangana/sakhi/app_config.dart'; // Import ShakeDetectionInitializer

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

  // Request permissions
  await _requestPermissions();

  // Initialize Shake Detection
  final shakeDetectionInitializer = ShakeDetectionInitializer();
  await shakeDetectionInitializer.initializeShakeDetection();

  runApp(WomenSafetyApp(shakeDetectionInitializer: shakeDetectionInitializer));
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
    Permission.activityRecognition, // Required for shake detection
  ];

  // Request each permission
  for (var permission in permissions) {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Handle permissions that are permanently denied
  if (await Permission.locationAlways.isPermanentlyDenied ||
      await Permission.activityRecognition.isPermanentlyDenied) {
    openAppSettings(); // Open app settings to manually enable permissions
  }
}

class WomenSafetyApp extends StatelessWidget {
  final ShakeDetectionInitializer shakeDetectionInitializer;

  const WomenSafetyApp({super.key, required this.shakeDetectionInitializer});

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
        home: const StartScreen(), // You can add logic here to go to HomeScreen if user is already logged in
      ),
    );
  }
}