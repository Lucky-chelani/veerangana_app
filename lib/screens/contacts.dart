import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:veerangana/screens/home_screen.dart';

class EmergencyContactScreen extends StatefulWidget {
  final String userPhone;

  const EmergencyContactScreen({super.key, required this.userPhone});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final List<Map<String, String>> contacts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingContacts();
  }

  Future<void> _loadExistingContacts() async {
    try {
      // Fetch existing emergency contacts from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userPhone)
          .get();

      if (userDoc.exists && userDoc.data()!.containsKey('emergencyContacts')) {
        final existingContacts = List<Map<String, dynamic>>.from(
            userDoc.data()!['emergencyContacts'] ?? []);

        setState(() {
          contacts.clear();
          for (var contact in existingContacts) {
            contacts.add({
              'name': contact['name'],
              'phone': contact['phone'],
            });
          }
        });
      }
    } catch (e) {
      print('Error loading existing contacts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading contacts: $e")),
      );
    }
  }

  Future<void> _askContactsPermission() async {
    // Request contacts permission
    final status = await Permission.contacts.request();

    if (status.isGranted) {
      await _pickContacts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission denied. Cannot access contacts."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickContacts() async {
    try {
      // Fetch all contacts
      Iterable<Contact> phoneContacts = await FlutterContacts.getContacts(
        withProperties: true,
      );

      // Create a list to hold the filtered contacts
      List<Contact> filteredContacts = phoneContacts.toList();

      // Show contact picker with search functionality
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          String searchQuery = "";

          return StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search contacts",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (query) {
                        searchQuery = query.toLowerCase();
                        setModalState(() {
                          filteredContacts = phoneContacts
                              .where((contact) =>
                                  contact.displayName != null &&
                                  contact.displayName!
                                      .toLowerCase()
                                      .contains(searchQuery))
                              .toList();
                        });
                      },
                    ),
                  ),
                  const Divider(),

                  // Contact List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        Contact contact = filteredContacts[index];
                        String phone = "";

                        if (contact.phones.isNotEmpty) {
                          phone = contact.phones.first.number ?? "";
                          // Clean the phone number
                          phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            child: contact.photo != null
                                ? ClipOval(
                                    child: Image.memory(
                                      contact.photo!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(contact.displayName?[0] ?? "?"),
                          ),
                          title: Text(contact.displayName ?? "Unknown"),
                          subtitle: Text(phone),
                          enabled: phone.isNotEmpty,
                          onTap: () {
                            Navigator.pop(context);

                            // Check if contact already exists
                            bool exists =
                                contacts.any((c) => c['phone'] == phone);
                            if (!exists) {
                              setState(() {
                                contacts.add({
                                  'name': contact.displayName ?? "Unknown",
                                  'phone': phone,
                                });
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Contact already added"),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error accessing contacts: $e")),
      );
    }
  }

  Future<void> saveContactsToFirestore() async {
    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one emergency contact")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userPhone)
          .update({
        'emergencyContacts': contacts,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Emergency contacts saved!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving contacts: $e")),
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
        title: const Text("Emergency Contacts",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
        backgroundColor: Colors.purple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  "Add trusted contacts who will be notified in case of emergency",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Add from contacts button
                ElevatedButton.icon(
                  onPressed: _askContactsPermission,
                  icon: const Icon(Icons.contact_phone),
                  label: const Text("Add from Phone Contacts"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),

                const SizedBox(height: 20),

                // Display selected contacts
                Expanded(
                  child: contacts.isEmpty
                      ? const Center(
                          child: Text(
                            "No emergency contacts added yet",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            final contact = contacts[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.purple[100],
                                  child: Text(
                                    contact['name']![0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(contact['name']!),
                                subtitle: Text(contact['phone']!),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      contacts.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 10),

                // Save button
                ElevatedButton(
                  onPressed: isLoading ? null : saveContactsToFirestore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    "Save & Continue",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
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
}