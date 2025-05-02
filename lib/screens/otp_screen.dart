import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number verified!")),
      );
      // Navigate to Home or main screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP")),
      );
    }

    setState(() {
      isVerifying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text("Enter OTP sent to ${widget.phone}"),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter 6-digit OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isVerifying ? null : verifyOtp,
              child: isVerifying
                  ? const CircularProgressIndicator()
                  : const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
