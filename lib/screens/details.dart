import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    userPhone = prefs.getString('userPhone') ?? ''; // Default to an empty string if not found

    if (userPhone.isNotEmpty) {
      await _fetchUserDetails(); // Fetch user details after loading phone number
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
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userPhone)
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching user details: $e"),
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
    };

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userPhone)
          .update(userDetails);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Details updated successfully!"),
            backgroundColor: AppColors.raspberry,
          ),
        );

        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNavBar(initialIndex: 0,)),
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

  // Future<void> _pickProfileImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(
  //     source: ImageSource.gallery,
  //     imageQuality: 80,
  //   );

  //   if (pickedFile != null) {
  //     setState(() {
  //       profileImage = File(pickedFile.path);
  //     });

  //     try {
  //       // Upload the image to Firebase Storage
  //       final storageRef = FirebaseStorage.instance
  //           .ref()
  //           .child('profile_photos/${userPhone}.jpg');
  //       final uploadTask = storageRef.putFile(profileImage!);

  //       // Show uploading progress
  //       setState(() {
  //         isLoading = true;
  //       });

  //       // Wait for the upload to complete
  //       final snapshot = await uploadTask;

  //       // Get the download URL
  //       final downloadUrl = await snapshot.ref.getDownloadURL();

  //       // Save the download URL in Firestore
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(userPhone)
  //           .update({'profilePhoto': downloadUrl});

  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("Profile photo updated successfully!"),
  //             backgroundColor: AppColors.raspberry,
  //           ),
  //         );
  //       }
  //     } catch (e) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text("Failed to upload profile photo: $e"),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     } finally {
  //       if (mounted) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //       }
  //     }
  //   }
  //    else {
  //   // If no photo is selected, create an empty tag in Firestore
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userPhone)
  //         .update({'profilePhoto': ''}); // Save an empty string as a placeholder

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text("No photo selected. Placeholder saved."),
  //           backgroundColor: Colors.orange,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Failed to save placeholder: $e"),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false, 
        title: const Text(
          "Your Profile",
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
                  // Profile photo section with elevated style
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepBurgundy.withValues(alpha:0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 65,
                              backgroundColor: Colors.white,
                              backgroundImage: 
                                   const AssetImage('assets/profile.jpeg') as ImageProvider,
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
                  ),

                  // Form section in a Card for better elevation
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
                          buildTextField(addressController, "Enter your address", Icons.location_on, TextInputType.multiline,),
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
                          disabledBackgroundColor: AppColors.salmonPink.withValues(alpha:0.5),
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
              color: Colors.black.withValues(alpha:0.3),
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
        hintStyle: TextStyle(color: AppColors.deepBurgundy.withValues(alpha:0.5)),
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
        fillColor: AppColors.lightPeach.withValues(alpha:0.3),
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

// class DetailsScreen extends StatefulWidget {
//   final String phone;

//   const DetailsScreen({super.key, required this.phone});

//   @override
//   State<DetailsScreen> createState() => _DetailsScreenState();
// }

// class _DetailsScreenState extends State<DetailsScreen> with SingleTickerProviderStateMixin {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController altPhoneController = TextEditingController();
//   final TextEditingController ageController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();

//   String selectedGender = 'Female';
//   final List<String> genders = ['Female', 'Male', 'Other'];

//   bool isLoading = false;
//   File? profileImage;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserDetails();

//     // Initialize animation controller
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     );
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchUserDetails() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.phone)
//           .get();

//       if (userDoc.exists) {
//         final data = userDoc.data()!;
//         nameController.text = data['name'] ?? '';
//         altPhoneController.text = data['altPhone'] ?? '';
//         ageController.text = data['age'] ?? '';
//         addressController.text = data['address'] ?? '';
//         selectedGender = data['gender'] ?? 'Female';
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error fetching user details: $e")),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//  Future<void> _saveDetails() async {
//   final userDetails = {
//     'name': nameController.text,
//     'altPhone': altPhoneController.text,
//     'gender': selectedGender,
//     'age': ageController.text,
//     'address': addressController.text,
//   };

//   setState(() {
//     isLoading = true;
//   });

//   try {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.phone)
//         .update(userDetails);

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Details updated successfully!")),
//     );

//     // Navigate to bottom navigation index 0
//    Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => const HomeScreen()),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Failed to update details: $e")),
//     );
//   } finally {
//     setState(() {
//       isLoading = false;
//     });
//   }
// }
//  Future<void> _pickProfileImage() async {
//   final picker = ImagePicker();
//   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//   if (pickedFile != null) {
//     setState(() {
//       profileImage = File(pickedFile.path);
//     });

//     try {
//       // Upload the image to Firebase Storage
//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('profile_photos/${widget.phone}.jpg'); // Use phone number as the file name
//       final uploadTask = storageRef.putFile(profileImage!);

//       // Wait for the upload to complete
//       final snapshot = await uploadTask;

//       // Get the download URL
//       final downloadUrl = await snapshot.ref.getDownloadURL();

//       // Save the download URL in Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.phone)
//           .update({'profilePhoto': downloadUrl});

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Profile photo updated successfully!")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to upload profile photo: $e")),
//       );
//     }
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Edit Your Details",
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: Colors.purple,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Stack(
//         children: [
//           FadeTransition(
//             opacity: _fadeAnimation,
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Profile Photo
//                   Center(
//                     child: GestureDetector(
//                       onTap: _pickProfileImage,
//                       child: CircleAvatar(
//                         radius: 60,
//                         backgroundImage: profileImage != null
//                             ? FileImage(profileImage!)
//                             : const AssetImage('assets/profile.jpeg') as ImageProvider,
//                         child: profileImage == null
//                             ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
//                             : null,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),



//                   buildLabel("Name"),
//                   buildTextField(nameController, "Enter your name"),
//                   buildLabel("Phone Number"),
//                   buildReadOnlyField(widget.phone),

//                   buildLabel("Alternative Phone Number"),
//                   buildTextField(altPhoneController, "Enter alternative phone number"),

//                   buildLabel("Gender"),
//                   DropdownButtonFormField<String>(
//                     value: selectedGender,
//                     items: genders.map((gender) {
//                       return DropdownMenuItem(value: gender, child: Text(gender));
//                     }).toList(),
//                     onChanged: (value) => setState(() => selectedGender = value!),
//                     decoration: const InputDecoration(border: OutlineInputBorder()),
//                   ),
//                   const SizedBox(height: 16),

//                   buildLabel("Age"),
//                   buildTextField(ageController, "Enter your age", TextInputType.number),

//                   buildLabel("Address"),
//                   buildTextField(addressController, "Enter your address", TextInputType.multiline),

//                   const SizedBox(height: 24),

//                   // Save Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: isLoading ? null : _saveDetails,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.purple,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: isLoading
//                           ? const CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             )
//                           : const Text(
//                               "Save and Continue",
//                               style: TextStyle(fontSize: 16, color: Colors.white),
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Loading Overlay
//           if (isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.3),
//               child: const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget buildLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 16.0, bottom: 4),
//       child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
//     );
//   }

//   Widget buildTextField(TextEditingController controller, String hint, [TextInputType? keyboard]) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboard,
//       decoration: InputDecoration(
//         hintText: hint,
//         border: const OutlineInputBorder(),
//       ),
//     );
//   }

//   Widget buildReadOnlyField(String value) {
//     return TextField(
//       readOnly: true,
//       controller: TextEditingController(text: value),
//       decoration: const InputDecoration(
//         border: OutlineInputBorder(),
//       ),
//     );
//   }
// }