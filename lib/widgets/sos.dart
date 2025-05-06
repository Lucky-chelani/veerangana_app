import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sms_sender/sms_sender.dart';
import 'package:vibration/vibration.dart';

class SosService {
  final SmsSender _smsSender = SmsSender();

  /// Send SOS SMS to emergency contacts
  Future<void> sendSos(String userPhone) async {
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
      String message = "SOS! I need help. My current location is: $locationUrl";

      // Get SIM card information (for dual SIM devices)
      List<Map<String, dynamic>> simCards = await SmsSender.getSimCards();
      int simSlot = simCards.isNotEmpty ? simCards[0]['simSlot'] : 0; // Default to SIM 1

      // Send SMS to emergency contacts
      for (String contact in emergencyContacts) {
        try {
          String status = await SmsSender.sendSms(
            phoneNumber: contact,
            message: message,
            simSlot: simSlot,
          );
          print("SOS SMS sent to $contact. Status: $status");
        } catch (e) {
          print("Failed to send SOS SMS to $contact: $e");
        }
      }

      // Vibrate once to indicate SOS is sent
      Vibration.vibrate(duration: 500); // Vibrate for 500ms

      print('SOS SMS sent to all emergency contacts.');
    } catch (e) {
      print("Error in SOS Service: $e");
    }
  }
}