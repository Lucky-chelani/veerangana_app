  import 'package:flutter/material.dart';

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

  String selectedGender = 'Female';

  final List<String> genders = ['Female', 'Male', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Details"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
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

            buildLabel("Address"),
            buildTextField(addressController, "Enter your address", TextInputType.multiline),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleAddEmergencyContact,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text("Add Emergency Contact"),
              ),
            )
          ],
        ),
      ),
    );
  }

  void handleAddEmergencyContact() {
    // You can validate and store data here or navigate to the next screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Proceed to add emergency contact")),
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
