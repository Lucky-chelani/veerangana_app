import 'dart:async';
import 'dart:convert';
import 'dart:math' as Math;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sms_sender/sms_sender.dart';
import 'package:vibration/vibration.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart'; // For playing sound
import 'package:fluttertoast/fluttertoast.dart'; // For showing toast messages

class PanicModeService {
  Timer? _smsTimer;
  Timer? _vibrationTimer;
  final SmsSender _smsSender = SmsSender();
  AudioPlayer? _audioPlayer;  // Audio player instance
  bool _isPanicModeActive = false;

  // Limit how many times SMS is sent (e.g., 6 messages = 30 seconds if interval is 5s)
  static const int maxSmsSends = 1;

  /// Activate Panic Mode
  Future<void> activatePanicMode(String userPhone) async {
    if (_isPanicModeActive) {
      print('Panic mode is already active.');
      return;
    }

    _isPanicModeActive = true;

    try {
      // Initialize audio player
      _audioPlayer = AudioPlayer();
      
      // Start playing sound and vibration immediately, don't wait for other operations
      _playBeepSound();
      _startVibration();

      // Fetch emergency contacts from Firestore
      final contactsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userPhone)
          .get();

      if (!contactsSnapshot.exists || contactsSnapshot.data() == null) {
        print('No emergency contacts found.');
        return;
      }

      final List<dynamic> emergencyContactsRaw =
          contactsSnapshot.data()!['emergencyContacts'] ?? [];

      final List<String> emergencyContacts = emergencyContactsRaw
          .where((contact) =>
              contact != null &&
              contact is Map<String, dynamic> &&
              contact['phone'] != null)
          .map((contact) => contact['phone'] as String)
          .toList();

      if (emergencyContacts.isEmpty) {
        print('No valid emergency contacts found.');
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String locationUrl =
          "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
      String message = "I need help! My current location is: $locationUrl";

      // Get SIM card information (for dual SIM devices)
      List<Map<String, dynamic>> simCards = await SmsSender.getSimCards();
      int simSlot = simCards.isNotEmpty ? simCards[0]['simSlot'] : 0; // Default to SIM 1

      int smsCount = 0;

      // Send SMS in parallel
      _smsTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (smsCount >= maxSmsSends) {
          timer.cancel();
          deactivatePanicMode(); // Automatically deactivate panic mode
          print('Maximum number of SMS messages sent. Stopping Panic Mode.');
          return;
        }

        // Send SMS to emergency contacts
        for (String contact in emergencyContacts) {
          try {
            String status = await SmsSender.sendSms(
              phoneNumber: contact,
              message: message,
              simSlot: simSlot,
            );
            print("SMS sent to $contact. Status: $status");
            
            await FirebaseFirestore.instance.collection('sent_sms').add({
              'phoneNumber': contact,
              'message': message,
              'timestamp': FieldValue.serverTimestamp(),
              'status': status,
              'userPhone': userPhone, // Add the user's phone number for reference
            });

            // Show toast message for each SMS sent
            Fluttertoast.showToast(
              msg: "SMS sent Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              backgroundColor: const Color.fromARGB(255, 69, 9, 32), // Burgundy background
              textColor: const Color(0xFFFFFFFF), // White text
              fontSize: 16.0,
            );
          } catch (e) {
            print("Failed to send SMS to $contact: $e");
            Fluttertoast.showToast(
              msg: "Failed to send SMS: ${e.toString().substring(0, Math.min(50, e.toString().length))}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              backgroundColor: const Color.fromARGB(255, 128, 0, 0), // Dark red for errors
              textColor: const Color(0xFFFFFFFF),
              fontSize: 16.0,
            );
          }
        }

        smsCount++;
      });

      print('Panic mode activated. SMS, vibration, and sound are running simultaneously.');
    } catch (e) {
      print("Error in Panic Mode: $e");
      _isPanicModeActive = false;
    }
  }

  /// Play beep sound - runs independently of other functions
  Future<void> _playBeepSound() async {
    try {
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer();
      }
      
      print("Loading beep sound...");
      await _audioPlayer!.setAsset('assets/sound.wav');
      await _audioPlayer!.setLoopMode(LoopMode.one); // Repeat indefinitely
      await _audioPlayer!.setVolume(1.0); // Full volume
      
      print("Playing beep sound...");
      await _audioPlayer!.play();
    } catch (e) {
      print("Error playing beep sound: $e");
      // Try to recover by reinitializing
      _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();
      try {
        await _audioPlayer!.setAsset('assets/sound.wav');
        await _audioPlayer!.setLoopMode(LoopMode.one);
        await _audioPlayer!.play();
      } catch (retryError) {
        print("Failed to recover audio playback: $retryError");
      }
    }
  }

  /// Start vibration pattern - runs independently of other functions
  Future<void> _startVibration() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        bool hasAmplitudeControl = await Vibration.hasAmplitudeControl() ?? false;
        
        // Check if device supports custom vibration patterns
        if (hasAmplitudeControl) {
          // SOS pattern (... --- ...) with varying intensities
          Vibration.vibrate(
            pattern: [0, 300, 200, 300, 200, 300, // S (3 short vibrations)
                    500, // pause
                    500, 250, 500, 250, 500, // O (3 long vibrations)
                    500, // pause
                    300, 200, 300, 200, 300], // S (3 short vibrations)
            intensities: hasAmplitudeControl ? 
                [0, 255, 0, 255, 0, 255, 
                 0, 
                 255, 0, 255, 0, 255, 
                 0, 
                 255, 0, 255, 0, 255] : [],
            repeat: -1, // -1 for repeat indefinitely
          );
        } else {
          // Simpler pattern for devices without amplitude control
          Vibration.vibrate(
            pattern: [0, 500, 500, 500, 500], // On-off-on-off pattern
            repeat: -1, // -1 for repeat indefinitely
          );
        }
        
        print("Vibration started");
      } else {
        print("Device does not support vibration");
      }
    } catch (e) {
      print("Error starting vibration: $e");
    }
  }

  /// Stop vibration
  void _stopVibration() {
    try {
      Vibration.cancel();
      if (_vibrationTimer != null) {
        _vibrationTimer!.cancel();
        _vibrationTimer = null;
      }
      print("Vibration stopped");
    } catch (e) {
      print("Error stopping vibration: $e");
    }
  }

  /// Deactivate Panic Mode - stops all ongoing processes
  Future<void> deactivatePanicMode() async {
    if (!_isPanicModeActive) {
      return;
    }
    
    _isPanicModeActive = false;
    
    // Cancel SMS timer
    if (_smsTimer != null) {
      _smsTimer!.cancel();
      _smsTimer = null;
    }
    
    // Stop vibration
    _stopVibration();
    
    // Stop audio
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        await _audioPlayer!.dispose();
        _audioPlayer = null;
      }
    } catch (e) {
      print("Error stopping audio: $e");
    }
    
    print('Panic mode fully deactivated.');
    
    // Show confirmation toast
    Fluttertoast.showToast(
      msg: "Panic mode deactivated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color.fromARGB(255, 0, 100, 0), // Green for success
      textColor: const Color(0xFFFFFFFF),
      fontSize: 16.0,
    );
  }

  /// Check if panic mode is currently active
  bool isPanicModeActive() {
    return _isPanicModeActive;
  }
}