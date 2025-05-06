import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Phone number verified!"),
            backgroundColor: AppColors.rosePink,
          ),
        );

        // Navigate to the details screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(phone: widget.phone),
          ),
        );
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
    return Scaffold(
      appBar: AppBar(
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
            colors: [AppColors.lightPeach, Colors.white],
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
                style: TextStyle(
                  color:AppColors.raspberry,
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
                child: TextButton(
                  onPressed: () {
                    // Implement resend OTP logic if needed
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.raspberry,
                  ),
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}