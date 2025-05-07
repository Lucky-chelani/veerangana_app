import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/ui/colors.dart';

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

    // Initialize animation controller
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
      userPhone = prefs.getString('userPhone') ?? ''; // Default to an empty string if not found
    });
  }

  Future<void> _saveDetails() async {
    // Validate fields
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
      'profilePhoto': '', // Default empty profile photo
    };

    setState(() {
      isLoading = true;
    });

    try {
      // Save user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userPhone)
          .set(userDetails);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Details saved successfully!"),
            backgroundColor: AppColors.raspberry,
          ),
        );

        // Navigate to home screen or another screen
        Navigator.of(context).pop();
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

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });

      try {
        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_photos/${userPhone}.jpg');
        final uploadTask = storageRef.putFile(profileImage!);

        // Show uploading progress
        setState(() {
          isLoading = true;
        });

        // Wait for the upload to complete
        final snapshot = await uploadTask;

        // Get the download URL
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Save the download URL in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userPhone)
            .update({'profilePhoto': downloadUrl});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile photo uploaded successfully!"),
              backgroundColor: AppColors.raspberry,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to upload profile photo: $e"),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Add Your Details",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Decorative top curved background
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.rosePink,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile photo section
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.white,
                            backgroundImage: profileImage != null
                                ? FileImage(profileImage!)
                                : const AssetImage('assets/profile.jpeg') as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.raspberry,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Form section
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBurgundy,
                            ),
                          ),
                          const SizedBox(height: 20),

                          buildLabel("Name"),
                          buildTextField(nameController, "Enter your name", Icons.person),

                          buildLabel("Phone Number"),
                          buildReadOnlyField(userPhone, Icons.phone),

                          buildLabel("Alternative Phone Number"),
                          buildTextField(altPhoneController, "Enter alternative phone", Icons.phone_android),

                          buildLabel("Gender"),
                          buildDropdown(),

                          buildLabel("Age"),
                          buildTextField(ageController, "Enter your age", Icons.calendar_today, TextInputType.number),

                          buildLabel("Address"),
                          buildTextField(addressController, "Enter your address", Icons.location_on, TextInputType.multiline),
                        ],
                      ),
                    ),
                  ),

                  // Save Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveDetails,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: AppColors.salmonPink.withOpacity(0.5),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
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

          // Loading Overlay
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

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.deepBurgundy,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, [
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
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }

  Widget buildReadOnlyField(String value, IconData icon) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.raspberry),
        filled: true,
        fillColor: AppColors.lightPeach.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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