import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:veerangana/screens/home_screen.dart';

class DetailsScreen extends StatefulWidget {
  final String phone;

  const DetailsScreen({super.key, required this.phone});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController altPhoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String selectedGender = 'Female';
  final List<String> genders = ['Female', 'Male', 'Other'];

  bool isLoading = false;
  File? profileImage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.phone)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        nameController.text = data['name'] ?? '';
        altPhoneController.text = data['altPhone'] ?? '';
        ageController.text = data['age'] ?? '';
        addressController.text = data['address'] ?? '';
        selectedGender = data['gender'] ?? 'Female';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user details: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

 Future<void> _saveDetails() async {
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
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.phone)
        .update(userDetails);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Details updated successfully!")),
    );

    // Navigate to bottom navigation index 0
   Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to update details: $e")),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
 Future<void> _pickProfileImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    setState(() {
      profileImage = File(pickedFile.path);
    });

    try {
      // Upload the image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos/${widget.phone}.jpg'); // Use phone number as the file name
      final uploadTask = storageRef.putFile(profileImage!);

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Save the download URL in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.phone)
          .update({'profilePhoto': downloadUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile photo updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload profile photo: $e")),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Your Details",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : const AssetImage('assets/profile.jpeg') as ImageProvider,
                        child: profileImage == null
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),



                  buildLabel("Name"),
                  buildTextField(nameController, "Enter your name"),
                  buildLabel("Phone Number"),
                  buildReadOnlyField(widget.phone),

                  buildLabel("Alternative Phone Number"),
                  buildTextField(altPhoneController, "Enter alternative phone number"),

                  buildLabel("Gender"),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    items: genders.map((gender) {
                      return DropdownMenuItem(value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedGender = value!),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),

                  buildLabel("Age"),
                  buildTextField(ageController, "Enter your age", TextInputType.number),

                  buildLabel("Address"),
                  buildTextField(addressController, "Enter your address", TextInputType.multiline),

                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              "Save and Continue",
                              style: TextStyle(fontSize: 16, color: Colors.white),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint, [TextInputType? keyboard]) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildReadOnlyField(String value) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }
}