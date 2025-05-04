import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sms_sender/sms_sender.dart';

class PanicModeService {
  Timer? _smsTimer;
  final SmsSender _smsSender = SmsSender();

  // Limit how many times SMS is sent (e.g., 6 messages = 30 seconds if interval is 5s)
  static const int maxSmsSends = 6;

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

      // Send SMS at interval with limit
      _smsTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (smsCount >= maxSmsSends) {
          timer.cancel();
          print('Maximum number of SMS messages sent. Stopping Panic Mode.');
          return;
        }

        for (String contact in emergencyContacts) {
          try {
            // Send SMS with selected SIM slot
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

        smsCount++;
      });

      print('Panic mode activated. SMS will be sent every 5 seconds.');
    } catch (e) {
      print("Error in Panic Mode: $e");
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