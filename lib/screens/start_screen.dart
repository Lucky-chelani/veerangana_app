import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/screens/shakeDetctionInitializer.dart';
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
     final ShakeDetectionInitializer _shakeDetectionInitializer = ShakeDetectionInitializer();
  bool isSendingOtp = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
    _initializeShakeDetection(); // Check if the user is already verified
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _initializeShakeDetection() async {
  _shakeDetectionInitializer.stopShakeDetection();
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
  final Size screenSize = MediaQuery.of(context).size;
  final double screenHeight = screenSize.height;
  final double screenWidth = screenSize.width;

  return Scaffold(
    body: Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
          ),
        ),

        // Foreground rounded container
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.035,
            ),
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
                    'assets/newlogo.jpg',
                    height: screenHeight * 0.08,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                const Text(
                  "Welcome to your safe space!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBurgundy,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                const Text(
                  "apki suraksha, hamari zimmedari",
                  style: TextStyle(color: AppColors.rosePink),
                ),
                SizedBox(height: screenHeight * 0.03),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter mobile number',
                    hintStyle: TextStyle(
                      color: AppColors.rosePink.withOpacity(0.7),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 10, right: 5),
                      child: Text(
                        '+91',
                        style: TextStyle(
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
                SizedBox(height: screenHeight * 0.025),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSendingOtp ? null : handleGetStarted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.raspberry,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.018,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.raspberry.withOpacity(0.6),
                    ),
                    child: isSendingOtp
                        ? SizedBox(
                            height: screenHeight * 0.025,
                            width: screenHeight * 0.025,
                            child: const CircularProgressIndicator(
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