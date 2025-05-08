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
  final int? resendToken;

  const OtpScreen({
    super.key, 
    required this.verificationId, 
    required this.phone, 
    this.resendToken
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isVerifying = false;
  bool canResendOtp = false; // Controls whether the "Resend OTP" button is enabled
  int timerSeconds = 30; // Countdown timer in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start the timer when the screen is initialized
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the screen is disposed
    otpController.dispose();
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

  void _resendOtp() async {
    setState(() {
      isVerifying = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}',
        forceResendingToken: widget.resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            await _saveAuthState();
            
            if (context.mounted) {
              _navigateBasedOnUserStatus();
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Authentication failed: ${e.toString()}"),
                  backgroundColor: AppColors.raspberry,
                ),
              );
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isVerifying = false;
          });
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Verification failed: ${e.message}"),
                backgroundColor: AppColors.raspberry,
              ),
            );
          }
        },
        codeSent: (String newVerificationId, int? newResendToken) {
          setState(() {
            isVerifying = false;
          });
          
          // Update the verification ID
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("OTP resent successfully!"),
                backgroundColor: AppColors.rosePink,
              ),
            );
          }
          
          // Update the UI state
          _startTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        isVerifying = false;
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to resend OTP: ${e.toString()}"),
            backgroundColor: AppColors.raspberry,
          ),
        );
      }
    }
  }

  Future<void> _saveAuthState() async {
    // Save verification status and phone number
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVerified', true);
    await prefs.setString('userPhone', widget.phone);
  }

  Future<void> _navigateBasedOnUserStatus() async {
    try {
      // Check if user exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.phone)
          .get();

      if (context.mounted) {
        if (userDoc.exists) {
          // Existing user: Navigate to HomeScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavBar(initialIndex: 0),
            ),
            (route) => false, // Remove all previous routes
          );
        } else {
          // New user: Navigate to AddDetailsScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDetailsScreen(),
            ),
            (route) => false, // Remove all previous routes
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error checking user data: ${e.toString()}"),
            backgroundColor: AppColors.raspberry,
          ),
        );
      }
    }
  }

  void verifyOtp() async {
    if (otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 6-digit OTP"),
          backgroundColor: AppColors.raspberry,
        ),
      );
      return;
    }

    setState(() {
      isVerifying = true;
    });

    try {
      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpController.text.trim(),
      );

      // Sign in with credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Save authentication state
      await _saveAuthState();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Phone number verified!"),
            backgroundColor: AppColors.rosePink,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate based on whether user exists or not
        await _navigateBasedOnUserStatus();
      }
    } catch (e) {
      setState(() {
        isVerifying = false;
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid OTP: ${e.toString()}"),
            backgroundColor: AppColors.raspberry,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Verification Code",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.deepBurgundy,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                "Enter OTP sent to +91 ${widget.phone}",
                style: const TextStyle(
                  color: AppColors.raspberry,
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: AppColors.deepBurgundy, fontSize: 18),
                decoration: InputDecoration(
                  hintText: "Enter 6-digit OTP",
                  hintStyle: TextStyle(color: AppColors.rosePink.withOpacity(0.7)),
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.raspberry,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.raspberry.withOpacity(0.6),
                  ),
                  child: isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
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
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: canResendOtp && !isVerifying ? _resendOtp : null,
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