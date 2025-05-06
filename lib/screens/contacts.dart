import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:veerangana/screens/home_screen.dart';
import 'package:veerangana/ui/colors.dart';


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
        SnackBar(
          content: Text("Error loading contacts: $e"),
          backgroundColor: Colors.red,
        ),
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
        backgroundColor: AppColors.lightPeach,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          String searchQuery = "";

          return StatefulBuilder(
            builder: (context, setModalState) {
              return DraggableScrollableSheet(
                initialChildSize: 0.75,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                expand: false,
                builder: (_, scrollController) {
                  return Column(
                    children: [
                      // Handle bar
                      Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.salmonPink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      
                      // Title
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          "Select Contact",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.deepBurgundy,
                          ),
                        ),
                      ),

                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search contacts",
                            prefixIcon: const Icon(Icons.search, color: AppColors.raspberry),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: AppColors.raspberry, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                      
                      const Divider(color: AppColors.salmonPink, thickness: 0.5),

                      // Contact List
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredContacts.length,
                          itemBuilder: (context, index) {
                            Contact contact = filteredContacts[index];
                            String phone = "";

                            if (contact.phones.isNotEmpty) {
                              phone = contact.phones.first.number ?? "";
                              // Clean the phone number
                              phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
                            }

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow( 
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.rosePink.withValues(alpha: 0.2),
                                  child: contact.photo != null
                                      ? ClipOval(
                                          child: Image.memory(
                                            contact.photo!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Text(
                                          contact.displayName?[0] ?? "?",
                                          style: const TextStyle(
                                            color: AppColors.deepBurgundy,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                title: Text(
                                  contact.displayName ?? "Unknown",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.deepBurgundy,
                                  ),
                                ),
                                subtitle: Text(
                                  phone,
                                  style: TextStyle(
                                    color: AppColors.deepBurgundy.withValues(alpha:0.7),
                                  ),
                                ),
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
                                        backgroundColor: AppColors.raspberry,
                                      ),
                                    );
                                  }
                                },
                              ),
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
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error accessing contacts: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveContactsToFirestore() async {
    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one emergency contact"),
          backgroundColor: AppColors.raspberry,
        ),
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
        SnackBar(
          content: Text("Error saving contacts: $e"),
          backgroundColor: Colors.red,
        ),
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
        title: const Text(
          "Emergency Contacts",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.rosePink,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background decoration
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.rosePink.withValues(alpha:0.1),
                    AppColors.lightPeach,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.rosePink.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.safety_divider_rounded,
                            size: 30,
                            color: AppColors.raspberry,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            "Add trusted contacts who will be notified in case of emergency",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.deepBurgundy,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Add from contacts button
                  ElevatedButton.icon(
                    onPressed: _askContactsPermission,
                    icon: const Icon(Icons.contact_phone),
                    label: const Text(
                      "Add from Phone Contacts",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(55),
                      backgroundColor: AppColors.raspberry,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title for contacts list
                  Row(
                    children: [
                      const Text(
                        "Added Contacts",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepBurgundy,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.salmonPink.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Display selected contacts
                  Expanded(
                    child: contacts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.contact_phone_outlined,
                                  size: 70,
                                  color: AppColors.salmonPink.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "No emergency contacts added yet",
                                  style: TextStyle(
                                    color: AppColors.salmonPink,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: contacts.length,
                            itemBuilder: (context, index) {
                              final contact = contacts[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.rosePink.withValues(alpha:0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.rosePink.withValues(alpha:0.2),
                                    radius: 25,
                                    child: Text(
                                      contact['name']![0].toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.deepBurgundy,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    contact['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.deepBurgundy,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      contact['phone']!,
                                      style: TextStyle(
                                        color: AppColors.deepBurgundy.withValues(alpha:0.7),
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.raspberry,
                                      size: 26,
                                    ),
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

                  const SizedBox(height: 20),

                  // Save button
                  ElevatedButton(
                    onPressed: isLoading ? null : saveContactsToFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.raspberry,
                      disabledBackgroundColor: AppColors.raspberry.withValues(alpha:0.5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Save & Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha:0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.raspberry),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Saving contacts...",
                        style: TextStyle(
                          color: AppColors.deepBurgundy,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// class EmergencyContactScreen extends StatefulWidget {
//   final String userPhone;

//   const EmergencyContactScreen({super.key, required this.userPhone});

//   @override
//   State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
// }

// class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
//   final List<Map<String, String>> contacts = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadExistingContacts();
//   }

//   Future<void> _loadExistingContacts() async {
//     try {
//       // Fetch existing emergency contacts from Firestore
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.userPhone)
//           .get();

//       if (userDoc.exists && userDoc.data()!.containsKey('emergencyContacts')) {
//         final existingContacts = List<Map<String, dynamic>>.from(
//             userDoc.data()!['emergencyContacts'] ?? []);

//         setState(() {
//           contacts.clear();
//           for (var contact in existingContacts) {
//             contacts.add({
//               'name': contact['name'],
//               'phone': contact['phone'],
//             });
//           }
//         });
//       }
//     } catch (e) {
//       print('Error loading existing contacts: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error loading contacts: $e")),
//       );
//     }
//   }

//   Future<void> _askContactsPermission() async {
//     // Request contacts permission
//     final status = await Permission.contacts.request();

//     if (status.isGranted) {
//       await _pickContacts();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Permission denied. Cannot access contacts."),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _pickContacts() async {
//     try {
//       // Fetch all contacts
//       Iterable<Contact> phoneContacts = await FlutterContacts.getContacts(
//         withProperties: true,
//       );

//       // Create a list to hold the filtered contacts
//       List<Contact> filteredContacts = phoneContacts.toList();

//       // Show contact picker with search functionality
//       await showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (context) {
//           String searchQuery = "";

//           return StatefulBuilder(
//             builder: (context, setModalState) {
//               return Column(
//                 children: [
//                   // Search Bar
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: "Search contacts",
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onChanged: (query) {
//                         searchQuery = query.toLowerCase();
//                         setModalState(() {
//                           filteredContacts = phoneContacts
//                               .where((contact) =>
//                                   contact.displayName != null &&
//                                   contact.displayName!
//                                       .toLowerCase()
//                                       .contains(searchQuery))
//                               .toList();
//                         });
//                       },
//                     ),
//                   ),
//                   const Divider(),

//                   // Contact List
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: filteredContacts.length,
//                       itemBuilder: (context, index) {
//                         Contact contact = filteredContacts[index];
//                         String phone = "";

//                         if (contact.phones.isNotEmpty) {
//                           phone = contact.phones.first.number ?? "";
//                           // Clean the phone number
//                           phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
//                         }

//                         return ListTile(
//                           leading: CircleAvatar(
//                             child: contact.photo != null
//                                 ? ClipOval(
//                                     child: Image.memory(
//                                       contact.photo!,
//                                       width: 40,
//                                       height: 40,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   )
//                                 : Text(contact.displayName?[0] ?? "?"),
//                           ),
//                           title: Text(contact.displayName ?? "Unknown"),
//                           subtitle: Text(phone),
//                           enabled: phone.isNotEmpty,
//                           onTap: () {
//                             Navigator.pop(context);

//                             // Check if contact already exists
//                             bool exists =
//                                 contacts.any((c) => c['phone'] == phone);
//                             if (!exists) {
//                               setState(() {
//                                 contacts.add({
//                                   'name': contact.displayName ?? "Unknown",
//                                   'phone': phone,
//                                 });
//                               });
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text("Contact already added"),
//                                 ),
//                               );
//                             }
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error accessing contacts: $e")),
//       );
//     }
//   }

//   Future<void> saveContactsToFirestore() async {
//     if (contacts.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please add at least one emergency contact")),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.userPhone)
//           .update({
//         'emergencyContacts': contacts,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Emergency contacts saved!"),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Navigate to HomeScreen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const HomeScreen(),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error saving contacts: $e")),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Emergency Contacts",
//         style: TextStyle(
//           fontSize: 22,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),),
//         backgroundColor: Colors.purple,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 const Text(
//                   "Add trusted contacts who will be notified in case of emergency",
//                   style: TextStyle(fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),

//                 // Add from contacts button
//                 ElevatedButton.icon(
//                   onPressed: _askContactsPermission,
//                   icon: const Icon(Icons.contact_phone),
//                   label: const Text("Add from Phone Contacts"),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size.fromHeight(50),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Display selected contacts
//                 Expanded(
//                   child: contacts.isEmpty
//                       ? const Center(
//                           child: Text(
//                             "No emergency contacts added yet",
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         )
//                       : ListView.builder(
//                           itemCount: contacts.length,
//                           itemBuilder: (context, index) {
//                             final contact = contacts[index];
//                             return Card(
//                               elevation: 2,
//                               margin: const EdgeInsets.symmetric(vertical: 8),
//                               child: ListTile(
//                                 leading: CircleAvatar(
//                                   backgroundColor: Colors.purple[100],
//                                   child: Text(
//                                     contact['name']![0].toUpperCase(),
//                                     style: const TextStyle(
//                                       color: Colors.purple,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 title: Text(contact['name']!),
//                                 subtitle: Text(contact['phone']!),
//                                 trailing: IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.red),
//                                   onPressed: () {
//                                     setState(() {
//                                       contacts.removeAt(index);
//                                     });
//                                   },
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ),

//                 const SizedBox(height: 10),

//                 // Save button
//                 ElevatedButton(
//                   onPressed: isLoading ? null : saveContactsToFirestore,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purple,
//                     minimumSize: const Size.fromHeight(50),
//                   ),
//                   child: const Text(
//                     "Save & Continue",
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Loading indicator
//           if (isLoading)
//             Container(
//               color: Colors.black.withValues(alpha: 0.3),
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
// }