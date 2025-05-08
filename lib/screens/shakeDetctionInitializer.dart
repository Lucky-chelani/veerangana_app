import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/screens/shakeDetecftion.dart';
import 'package:veerangana/widgets/panicmode.dart';

class ShakeDetectionInitializer {
  late ShakeDetectionService _shakeDetectionService;
  late PanicModeService _panicModeService;

  /// Initialize Shake Detection
  Future<void> initializeShakeDetection() async {
    _panicModeService = PanicModeService();
    _shakeDetectionService = ShakeDetectionService(_panicModeService);

    // Load user phone and start shake detection
    await _loadUserPhoneAndStartShakeDetection();
  }

  Future<void> _loadUserPhoneAndStartShakeDetection() async {
    final prefs = await SharedPreferences.getInstance();
    String userPhone = prefs.getString('userPhone') ?? '1234567890'; // Replace with actual logic
    _shakeDetectionService.startListening(userPhone);
  }

  /// Stop Shake Detection
  void stopShakeDetection() {
    _shakeDetectionService.stopListening();
  }
}