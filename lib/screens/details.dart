import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veerangana/screens/contacts.dart' as contacts;
import 'package:veerangana/screens/home_screen.dart';

class DetailsScreen extends StatefulWidget {
  final String phone;

  const DetailsScreen({super.key, required this.phone});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController altPhoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  //final TextEditingController cityController = TextEditingController();

  String selectedGender = 'Female';
  final List<String> genders = ['Female', 'Male', 'Other'];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingDetails();
  }

  Future<void> _checkExistingDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch user details from Firebase
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.phone)
          .get();

      if (userDoc.exists) {
        // If details exist, navigate directly to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      // Handle error (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error checking user details: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Details",
         style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
        backgroundColor: Colors.purple,
        iconTheme: IconThemeData(color: Colors.white),),
       
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLabel("Phone Number"),
                buildReadOnlyField(widget.phone),

                buildLabel("Name"),
                buildTextField(nameController, "Enter your name"),

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

                //buildLabel("City"),
                //buildTextField(cityController, "Enter your city"),

                buildLabel("Address"),
                buildTextField(addressController, "Enter your address", TextInputType.multiline),

                const SizedBox(height: 24),

                // Save and Navigate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveDetailsAndNavigate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            "Save & Continue",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha:0.3),
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

  Future<void> saveDetailsAndNavigate() async {
    final userDetails = {
      'phone': widget.phone,
      'name': nameController.text,
      'altPhone': altPhoneController.text,
      'gender': selectedGender,
      'age': ageController.text,
      //'city': cityController.text,
      'address': addressController.text,
    };

    setState(() {
      isLoading = true;
    });

    try {
      // Save details to Firebase
      await FirebaseFirestore.instance.collection('users').doc(widget.phone).set(userDetails);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details saved successfully!")),
      );

      // Navigate to EmergencyContactScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => contacts.EmergencyContactScreen(userPhone: widget.phone),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save details: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
        border: OutlineInputBorder(),
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