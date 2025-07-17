import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/screens/addDetails.dart';
import 'package:veerangana/widgets/custom_bottom_nav.dart';
import 'details.dart';
import 'package:veerangana/ui/colors.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phone;

  const OtpScreen({super.key, required this.verificationId, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}



class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isVerifying = false;
  bool canResendOtp = false; // Controls whether the "Resend OTP" button is enabled
  int timerSeconds = 60; // Countdown timer in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start the timer when the screen is initialized
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      canResendOtp = false; // Disable the "Resend OTP" button
      timerSeconds = 30; // Reset the timer to 30 seconds
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds > 0) {
        setState(() {
          timerSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          canResendOtp = true; // Enable the "Resend OTP" button
        });
      }
    });
  }

  void _resendOtp() {
    // Logic to resend OTP
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP resent successfully!")),
    );

    _startTimer(); // Restart the timer after resending OTP
  }

  void verifyOtp() async {
  setState(() {
    isVerifying = true;
  });

  final credential = PhoneAuthProvider.credential(
    verificationId: widget.verificationId,
    smsCode: otpController.text.trim(),
  );

  try {
    await FirebaseAuth.instance.signInWithCredential(credential);

    // ✅ Save phone number to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhone', widget.phone);

    // Check if the user already exists in Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.phone)
        .get();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phone number verified!"),
          backgroundColor: AppColors.rosePink,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate based on whether the user is new or existing
      if (userDoc.exists) {
        // Existing user: Navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavBar(initialIndex: 0),
          ),
        );
      } else {
        // New user: Navigate to AddDetailsScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AddDetailsScreen(),
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid OTP"),
          backgroundColor: AppColors.raspberry,
        ),
      );
    }
  }

  setState(() {
    isVerifying = false;
  });
}
  @override
Widget build(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  final double screenHeight = screenSize.height;
  final double screenWidth = screenSize.width;

  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text("Verify OTP"),
      backgroundColor: AppColors.rosePink,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.lightPeach, AppColors.salmonPink],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.03),
            Text(
              "Verification Code",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.deepBurgundy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              "Enter OTP sent to +91 ${widget.phone}",
              style: TextStyle(
                color: AppColors.raspberry,
                fontSize: screenHeight * 0.021, // ~16 on normal screen
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(
                color: AppColors.deepBurgundy,
                fontSize: screenHeight * 0.023,
              ),
              decoration: InputDecoration(
                hintText: "Enter 6-digit OTP",
                hintStyle: TextStyle(
                  color: AppColors.rosePink.withOpacity(0.7),
                ),
                counterText: "",
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.raspberry, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.salmonPink),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isVerifying ? null : verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.raspberry,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.raspberry.withOpacity(0.6),
                ),
                child: isVerifying
                    ? SizedBox(
                        height: screenHeight * 0.025,
                        width: screenHeight * 0.025,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Verify",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: canResendOtp ? _resendOtp : null,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.raspberry,
                    ),
                    child: Text(
                      canResendOtp ? "Resend OTP" : "Resend OTP in $timerSeconds seconds",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}