import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/widgets/custom_bottom_nav.dart';
import 'otp_screen.dart';
import 'details.dart';
import 'package:veerangana/ui/colors.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isSendingOtp = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus(); // Check if the user is already verified
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _checkVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isVerified = prefs.getBool('isVerified') ?? false;

    if (isVerified) {
      final userPhone = prefs.getString('userPhone') ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(),
        ),
      );
    }
  }

  void handleGetStarted() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty || phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit phone number"),
          backgroundColor: AppColors.raspberry,
        ),
      );
      return;
    }

    setState(() {
      isSendingOtp = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically sign in the user
        await FirebaseAuth.instance.signInWithCredential(credential);

        // Save verification status and phone number
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isVerified', true);
        await prefs.setString('userPhone', phone);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBar(initialIndex: 2,),
            ),
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          isSendingOtp = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Verification failed: ${e.message}"),
            backgroundColor: AppColors.raspberry,
          ),
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
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with color overlay
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                const Color.fromARGB(255, 255, 165, 171).withValues(alpha:0.8),
                BlendMode.overlay,
              ),
              child: Image.asset(
                'assets/bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground rounded container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x20000000),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/veerlogo.jpg',
                      height: 70,
                    ),
                  ),
                    // ClipRRect(
                    // borderRadius: BorderRadius.circular(12),
                    // child: Image.asset(
                    //   'assets/newlogo.jpg',
                    //   height: 50,
                    // ),
                    // ),
                     const SizedBox(height: 16),
                  const Text(
                    "Welcome to your safe space!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBurgundy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your safety is our priority",
                    style: TextStyle(color: AppColors.rosePink),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                   controller: phoneController,
                   keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                   hintText: 'Enter mobile number',
                   hintStyle: TextStyle(color: AppColors.rosePink.withOpacity(0.7)),
                    prefixIcon: Padding(
                   padding: const EdgeInsets.only(left: 10, right: 5),
                    child: Text(
                    '+91',
                   style: const TextStyle(
                  color: AppColors.rosePink,
                 fontSize: 16,
                  fontWeight: FontWeight.bold,
                 ),
      ),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.raspberry, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.salmonPink),
    ),
  ),
),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSendingOtp ? null : handleGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.raspberry,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: AppColors.raspberry.withOpacity(0.6),
                      ),
                      child: isSendingOtp
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Get Started",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}