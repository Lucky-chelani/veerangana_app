import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sms_sender/sms_sender.dart';
import 'package:vibration/vibration.dart';
import 'package:http/http.dart' as http;

class PanicModeService {
  Timer? _smsTimer;
  final SmsSender _smsSender = SmsSender();

  // Limit how many times SMS is sent (e.g., 6 messages = 30 seconds if interval is 5s)
  static const int maxSmsSends = 6;

  // FCM server key and endpoint
  static const String serverKey = 'STQWgrbY-VIWXpFeErAMQy2srhm0vqP1HNPIkqC0vk4'; // Replace with your FCM server key
  static const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  /// Activate Panic Mode
  Future<void> activatePanicMode(String userPhone) async {
    try {
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

      // Start vibration at intervals
      Timer? vibrationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (smsCount >= maxSmsSends) {
          timer.cancel(); // Stop vibration timer after sending all SMS
        } else {
          Vibration.vibrate(duration: 500); // Vibrate for 500ms
        }
      });

      // Send SMS at interval with limit
      _smsTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (smsCount >= maxSmsSends) {
          timer.cancel();
          vibrationTimer?.cancel(); // Stop vibration when panic mode deactivates
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
          } catch (e) {
            print("Failed to send SMS to $contact: $e");
          }
        }

        // Send FCM notifications to all users
        await _sendNotificationToAllUsers(locationUrl);

        smsCount++;
      });

      print('Panic mode activated. SMS and notifications will be sent every 5 seconds.');
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

  /// Deactivate Panic Mode
  void deactivatePanicMode() {
    if (_smsTimer != null) {
      _smsTimer!.cancel();
      _smsTimer = null;
      print('Panic mode deactivated.');
    }
  }
}