import 'dart:async';
import 'dart:convert';
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
  final SmsSender _smsSender = SmsSender();
  AudioPlayer? _audioPlayer;  // Audio player instance

  // Limit how many times SMS is sent (e.g., 6 messages = 30 seconds if interval is 5s)
  static const int maxSmsSends = 6;

  // FCM server key and endpoint
  static const String serverKey = 'STQWgrbY-VIWXpFeErAMQy2srhm0vqP1HNPIkqC0vk4'; // Replace with your FCM server key
  static const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  /// Activate Panic Mode
  Future<void> activatePanicMode(String userPhone) async {
  try {
          _audioPlayer = AudioPlayer();
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

    // Start playing the beep sound in parallel
    _playBeepSound();

    // Start vibration in parallel
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (smsCount >= maxSmsSends) {
        timer.cancel(); // Stop vibration timer after sending all SMS
      } else {
        // Vibrate for 1 second with high intensity
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 1000, amplitude: 255); // 1000ms, max intensity
        }
      }
    });

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

          // Show toast message for each SMS sent
          Fluttertoast.showToast(
            msg: "SMS sent Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color.fromARGB(255, 69, 9, 32), // Green background
            textColor: const Color(0xFFFFFFFF), // White text
            fontSize: 16.0,
          );
        } catch (e) {
          print("Failed to send SMS to $contact: $e");
        }
      }

      smsCount++;
    });

    // Send FCM notification in parallel
    Future.delayed(Duration.zero, () async {
      await _sendNotificationToAllUsers(locationUrl);
    });

    print('Panic mode activated. SMS, notifications, vibration, and sound are running in parallel.');
  } catch (e) {
    print("Error in Panic Mode: $e");
  }
}

  /// Send Notification via FCM to All Users
  Future<void> _sendNotificationToAllUsers(String locationUrl) async {
    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': '/topics/global_alerts', // Send to the "global_alerts" topic
          'notification': {
            'title': 'Emergency Alert!',
            'body': 'I need help! My current location is: $locationUrl',
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'locationUrl': locationUrl,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully to all users.');
      } else {
        print('Failed to send notification to all users: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification to all users: $e');
    }
  }

  /// Play beep sound
/// Play beep sound in a loop
  Future<void> _playBeepSound() async {
    try {
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer(); // Reinitialize if null
      }
      await _audioPlayer!.setAsset('assets/sound.wav'); // Add a beep sound file to your assets
      await _audioPlayer!.setLoopMode(LoopMode.one); // Repeat the sound indefinitely
      await _audioPlayer!.play();
    } catch (e) {
      print("Error playing beep sound: $e");
    }
  }

  /// Deactivate Panic Mode
  void deactivatePanicMode() {
    if (_smsTimer != null) {
      _smsTimer!.cancel();
      _smsTimer = null;
      print('Panic mode deactivated.');
    }
    if (_audioPlayer != null) {
      _audioPlayer!.stop(); // Stop the audio playback
      _audioPlayer!.dispose(); // Dispose of the audio player
      _audioPlayer = null; // Set to null for reinitialization
    }
  }
}