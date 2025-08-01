import '../config/environment_config.dart';

class AppConfig {
  // Gemini API Configuration
  static String get geminiApiKey => EnvironmentConfig.geminiApiKey;
  
  // Sakhi Chatbot Configuration
  static const String sakhiName = 'Sakhi';
  static const String sakhiWelcomeMessage = 
      "नमस्ते! मैं सखी हूँ, आपकी सुरक्षा सहायक। मैं आपको मार्गदर्शन और भावनात्मक सहायता प्रदान करने के लिए यहां हूं। मैं आपकी कैसे मदद कर सकती हूँ?\n\n(Hello! I'm Sakhi, your safety assistant. I'm here to provide guidance and emotional support whenever you need. How can I help you today?)";
  
  // Emergency Contact Numbers (India)
  static const String emergencyPoliceNumber = '100';
  static const String emergencyWomenHelplineNumber = '1091';
  static const String emergencyAmbulanceNumber = '102';
  static const String emergencyChildHelplineNumber = '1098';
  
  // App Information
  static String get appName => EnvironmentConfig.appName;
  static String get appVersion => EnvironmentConfig.appVersion;
}