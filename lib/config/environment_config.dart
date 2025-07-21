import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  // Firebase Configuration
  static String get firebaseWebApiKey => 
      dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';
  
  static String get firebaseAndroidApiKey => 
      dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '';
  
  static String get firebaseIosApiKey => 
      dotenv.env['FIREBASE_IOS_API_KEY'] ?? '';
  
  static String get firebaseWebAppId => 
      dotenv.env['FIREBASE_WEB_APP_ID'] ?? '';
  
  static String get firebaseAndroidAppId => 
      dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '';
  
  static String get firebaseIosAppId => 
      dotenv.env['FIREBASE_IOS_APP_ID'] ?? '';
  
  static String get firebaseMessagingSenderId => 
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  
  static String get firebaseProjectId => 
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  
  static String get firebaseAuthDomain => 
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  
  static String get firebaseStorageBucket => 
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  
  static String get firebaseMeasurementIdWeb => 
      dotenv.env['FIREBASE_MEASUREMENT_ID_WEB'] ?? '';
  
  static String get firebaseMeasurementIdWindows => 
      dotenv.env['FIREBASE_MEASUREMENT_ID_WINDOWS'] ?? '';
  
  static String get firebaseIosBundleId => 
      dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? '';

  // Google APIs
  static String get googleMapsApiKey => 
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  
  static String get geminiApiKey => 
      dotenv.env['GEMINI_API_KEY'] ?? '';

  // App Configuration
  static String get appName => 
      dotenv.env['APP_NAME'] ?? 'Veerangana';
  
  static String get appVersion => 
      dotenv.env['APP_VERSION'] ?? '1.0.0';
}
