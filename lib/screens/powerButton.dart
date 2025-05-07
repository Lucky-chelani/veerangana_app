// // lib/shake_background_service.dart
// import 'dart:async';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:shake_detector/shake_detector.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';

// const String channelId = 'shake_service_channel';
// const String channelName = 'Shake Background Service';
// const String channelDescription = 'Detects shake gestures in the background.';

// Future<void> initializeService() async {

//   final service = FlutterBackgroundService();
//   ShakeDetector.autoStart(
//     onShake: () async {
//       print('Shake detected in background!');
//       // Perform your panic action here
// // Pass the plugin instance
//     },
//     shakeThresholdGravity: 0.2, // Adjust sensitivity as needed
//   );
//     print('hello4');
// }


// // to ensure this is executed
// // run app in debug mode
// // and ensure flutter has been initialized
// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();

//   return true;
// }

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();
//     print('hello10');


//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//         print('hello5');
//     });

//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//         print('hello6');
//     });
//   }

//   service.on('stopService').listen((event) {
//     service.stopSelf();
//       print('bye');
//   });

//   ShakeDetector.autoStart(
//     onShake: () async {
//       print('Shake detected in background!');
//       // Perform your panic action here
// // Pass the plugin instance
//     },
//     shakeThresholdGravity: 0.2, // Adjust sensitivity as needed
//   );

//   // Bring the service to the foreground (optional, but recommended for reliability)
//   Future.delayed(const Duration(seconds: 1), () async {
//     if (service is AndroidServiceInstance) {
//       service.setForegroundNotificationInfo(
//         title: "Shake Service Running",
//         content: "Detecting shakes...",
//       );
//     }
//   });
// }

// Future<void> _sendPanicAlert() async {
//   // 1. Get current location (requires background location permission)
//   Position? position = await _getCurrentLocation();
//   String locationMessage = position != null
//       ? 'My location: Latitude ${position.latitude}, Longitude ${position.longitude}'
//       : 'Could not get location in background.';

//   // 2. Send SMS (requires send SMS permission)
//   List<String> recipients = ['+1234567890']; // Replace with emergency contacts
//   String message = 'EMERGENCY! Shake detected in background. $locationMessage';
//   //await sendSMS(message: message, recipients: recipients).catchError((error) {
//   //  print('SMS Error in background: $error');
//   //});

//   // 3. Optionally make a call (requires call phone permission)
//   const emergencyNumber = '112';
//   final Uri callUri = Uri(scheme: 'tel', path: emergencyNumber);
//   // if (await canLaunchUrl(callUri)) {
//   //   await launchUrl(callUri);
//   // } else {
//   //   print('Could not launch $callUri in background');
//   // }

//   // 4. Show a local notification to indicate the action
  

// }

// Future<Position?> _getCurrentLocation() async {
//   PermissionStatus permission = await Permission.locationAlways.status;
//   if (!permission.isGranted) {
//     permission = await Permission.locationAlways.request();
//     if (!permission.isGranted) {
//       print('Background location permission denied.');
//       return null;
//     }
//   }
//   try {
//     return await Geolocator.getCurrentPosition();
//   } catch (e) {
//     print('Error getting background location: $e');
//     return null;
//   }
// }