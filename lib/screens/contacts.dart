import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

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
    _checkPermissionAndLoadExistingContacts();
  }

  Future<void> _checkPermissionAndLoadExistingContacts() async {
    // Check if we have existing contacts saved for this user
    try {
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
    }
  }

  Future<void> _askContactsPermission() async {
    setState(() {
      isLoading = true;
    });
    
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
    
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickContacts() async {
    try {
      // Get all contacts
      Iterable<Contact> phoneContacts = await ContactsService.getContacts();
      
      // Show contact picker
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Select Emergency Contacts",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: phoneContacts.length,
                  itemBuilder: (context, index) {
                    Contact contact = phoneContacts.elementAt(index);
                    String phone = "";
                    
                    if (contact.phones != null && contact.phones!.isNotEmpty) {
                      phone = contact.phones!.first.value ?? "";
                      // Clean the phone number
                      phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
                    }
                    
                    return ListTile(
                      leading: CircleAvatar(
                        child: contact.avatar != null && contact.avatar!.isNotEmpty
                            ? ClipOval(
                                child: Image.memory(
                                  contact.avatar!,
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
                        bool exists = contacts.any((c) => c['phone'] == phone);
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
          ),
        ),
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

      // Navigate to next screen - you can add your navigation code here
      // Navigator.pushReplacement(
      //   context, 
      //   MaterialPageRoute(builder: (context) => NextScreen()),
      // );
      
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
        title: const Text("Emergency Contacts"),
        backgroundColor: Colors.purple,
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
              color: Colors.black.withValues(alpha: .3),
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