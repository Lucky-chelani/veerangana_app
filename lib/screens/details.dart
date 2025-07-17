import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/screens/shakeDetctionInitializer.dart';
import 'package:veerangana/screens/start_screen.dart';
import 'dart:io';
import 'package:veerangana/ui/colors.dart';
import 'package:veerangana/widgets/custom_bottom_nav.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController altPhoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final ShakeDetectionInitializer _shakeDetectionInitializer = ShakeDetectionInitializer();

  String selectedGender = 'Female';
  final List<String> genders = ['Female', 'Male', 'Other'];
  String userPhone = '';
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserPhone();
    _fetchUserDetails();
    _initializeShakeDetection();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  Future<void> _initializeShakeDetection() async {
    await _shakeDetectionInitializer.initializeShakeDetection();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    altPhoneController.dispose();
    ageController.dispose();
    addressController.dispose();
    _shakeDetectionInitializer.stopShakeDetection();
    super.dispose();
  }

  Future<void> _loadUserPhone() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    userPhone = prefs.getString('userPhone') ?? '';

    if (userPhone.isNotEmpty) {
      await _fetchUserDetails();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userPhone).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        nameController.text = data['name'] ?? '';
        altPhoneController.text = data['altPhone'] ?? '';
        ageController.text = data['age'] ?? '';
        addressController.text = data['address'] ?? '';
        selectedGender = data['gender'] ?? 'Female';
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Details fetched successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveDetails() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userDetails = {
      'name': nameController.text,
      'altPhone': altPhoneController.text,
      'gender': selectedGender,
      'age': ageController.text,
      'address': addressController.text,
    };

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(userPhone).update(userDetails);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Details updated successfully!"),
            backgroundColor: AppColors.raspberry,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNavBar(initialIndex: 0)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update details: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      _shakeDetectionInitializer.stopShakeDetection();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StartScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to log out: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Your Profile",
          style: TextStyle(
            fontSize: screenHeight * 0.028,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            height: screenHeight * 0.12,
            decoration: const BoxDecoration(
              color: AppColors.rosePink,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: screenHeight * 0.025,
                        bottom: screenHeight * 0.04,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepBurgundy.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: screenWidth * 0.17,
                            backgroundColor: Colors.white,
                            backgroundImage: const AssetImage('assets/profile.jpeg'),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.025),
                              decoration: BoxDecoration(
                                color: AppColors.raspberry,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: screenWidth * 0.045,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: EdgeInsets.only(bottom: screenHeight * 0.03),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: screenHeight * 0.022,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBurgundy,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.025),

                          buildLabel("Name", screenHeight),
                          buildTextField(nameController, "Enter your name", Icons.person, screenWidth, screenHeight),

                          buildLabel("Phone Number", screenHeight),
                          buildReadOnlyField(userPhone, Icons.phone, screenWidth, screenHeight),

                          buildLabel("Alternative Phone Number", screenHeight),
                          buildTextField(altPhoneController, "Enter alternative phone", Icons.phone_android, screenWidth, screenHeight),

                          buildLabel("Gender", screenHeight),
                          buildDropdown(),

                          buildLabel("Age", screenHeight),
                          buildTextField(ageController, "Enter your age", Icons.calendar_today, screenWidth, screenHeight, TextInputType.number),

                          buildLabel("Address", screenHeight),
                          buildTextField(addressController, "Enter your address", Icons.location_on, screenWidth, screenHeight, TextInputType.multiline),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveDetails,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.022),
                          disabledBackgroundColor: AppColors.salmonPink.withOpacity(0.5),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: screenHeight * 0.025,
                                width: screenHeight * 0.025,
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Save and Continue",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.raspberry,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.022),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.raspberry),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildLabel(String text, double screenHeight) {
    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.02, bottom: screenHeight * 0.01),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.deepBurgundy,
          fontSize: screenHeight * 0.018,
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    double screenWidth,
    double screenHeight, [
    TextInputType? keyboard,
    int maxLines = 1,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.deepBurgundy.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: AppColors.raspberry),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.045,
        ),
      ),
    );
  }

  Widget buildReadOnlyField(String value, IconData icon, double screenWidth, double screenHeight) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.raspberry),
        filled: true,
        fillColor: AppColors.lightPeach.withOpacity(0.3),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.045,
        ),
      ),
    );
  }

  Widget buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      dropdownColor: Colors.white,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.raspberry),
      items: genders.map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender));
      }).toList(),
      onChanged: (value) => setState(() => selectedGender = value!),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.people, color: AppColors.raspberry),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}
