import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isSendingOtp = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void handleGetStarted() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty || phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 10-digit phone number")),
      );
      return;
    }

    setState(() {
      isSendingOtp = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (PhoneAuthCredential credential) {
        // Optional: Auto sign-in
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          isSendingOtp = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          isSendingOtp = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              verificationId: verificationId,
              phone: phone,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Optional: Handle timeout
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const Text(
                "Welcome to your safe space!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 30),

              // Logo
              Image.asset(
                'assets/hack.jpeg',
                height: 120,
              ),
              const SizedBox(height: 40),

              // Phone Number Field
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSendingOtp ? null : handleGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSendingOtp
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Get Started",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
