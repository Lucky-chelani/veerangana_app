import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:veerangana/widgets/panicmode.dart';

class ShakeDetectionService {
  static const double shakeThreshold = 15.0; // Adjust this value for sensitivity
  static const int debounceDuration = 2000; // 2 seconds debounce to avoid multiple triggers
  AccelerometerEvent? _lastEvent;
  Timer? _debounceTimer;
  final PanicModeService _panicModeService;

  ShakeDetectionService(this._panicModeService);

  /// Start listening for shake events
  void startListening(String userPhone) {
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (_lastEvent != null) {
        double deltaX = (event.x - _lastEvent!.x).abs();
        double deltaY = (event.y - _lastEvent!.y).abs();
        double deltaZ = (event.z - _lastEvent!.z).abs();

        double shakeMagnitude = deltaX + deltaY + deltaZ;

        if (shakeMagnitude > shakeThreshold) {
          if (_debounceTimer == null || !_debounceTimer!.isActive) {
            _debounceTimer = Timer(Duration(milliseconds: debounceDuration), () {});
            print("Shake detected! Activating Panic Mode...");
            _panicModeService.activatePanicMode(userPhone);
          }
        }
      }
      _lastEvent = event;
    }, onError: (error) {
      print("Error in accelerometer events: $error");
    }, cancelOnError: true);
  }

  /// Stop listening for shake events
  void stopListening() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    print("Shake detection stopped.");
  }
}