import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/ui/colors.dart';
import 'package:veerangana/widgets/custom_bottom_nav.dart';

class AddDetailsScreen extends StatefulWidget {
  const AddDetailsScreen({super.key});

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController altPhoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String selectedGender = 'Female';
  final List<String> genders = ['Female', 'Male', 'Other'];
  String userPhone = '';
  bool isLoading = false;
  File? profileImage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserPhone();

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

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    altPhoneController.dispose();
    ageController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userPhone = prefs.getString('userPhone') ?? '';
    });
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
      await FirebaseFirestore.instance.collection('users').doc(userPhone).set(userDetails);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Details saved successfully!"),
            backgroundColor: AppColors.raspberry,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar(initialIndex: 0)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save details: $e"),
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Add Your Details",
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
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: GestureDetector(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: screenWidth * 0.17,
                            backgroundColor: Colors.white,
                            backgroundImage: profileImage != null
                                ? FileImage(profileImage!)
                                : const AssetImage('assets/profile.jpeg') as ImageProvider,
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
                  SizedBox(height: screenHeight * 0.03),
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
                          buildTextField(nameController, "Enter your name", Icons.person, screenHeight, screenWidth),

                          buildLabel("Phone Number", screenHeight),
                          buildReadOnlyField(userPhone, Icons.phone, screenHeight, screenWidth),

                          buildLabel("Alternative Phone Number", screenHeight),
                          buildTextField(altPhoneController, "Enter alternative phone", Icons.phone_android, screenHeight, screenWidth),

                          buildLabel("Gender", screenHeight),
                          buildDropdown(screenHeight),

                          buildLabel("Age", screenHeight),
                          buildTextField(ageController, "Enter your age", Icons.calendar_today, screenHeight, screenWidth, TextInputType.number),

                          buildLabel("Address", screenHeight),
                          buildTextField(addressController, "Enter your address", Icons.location_on, screenHeight, screenWidth, TextInputType.multiline),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.04),
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
    double screenHeight,
    double screenWidth, [
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

  Widget buildReadOnlyField(String value, IconData icon, double screenHeight, double screenWidth) {
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

  Widget buildDropdown(double screenHeight) {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      dropdownColor: Colors.white,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.raspberry),
      items: genders.map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender));
      }).toList(),
      onChanged: (value) => setState(() => selectedGender = value!),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.people, color: AppColors.raspberry),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: 20,
        ),
      ),
    );
  }
}
