import 'package:crm_mobile/features/contacts/contact_add_edit.dart';
import 'package:crm_mobile/services/api_service.dart';
import 'package:crm_mobile/shared/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';

class Contact {
  final String name;
  final String accountName;
  final String email;
  final String phone;
  final String title;
  final String imageUrl;

  Contact({
    required this.name,
    required this.accountName,
    required this.email,
    required this.phone,
    required this.title,
    required this.imageUrl,
  });
}

class ContactListWidget extends StatefulWidget {
  const ContactListWidget({super.key});

  @override
  State<ContactListWidget> createState() => _ContactListWidgetState();
}

class _ContactListWidgetState extends State<ContactListWidget> {
  List<Contact> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers(); // ✅ call API when widget loads
  }

  Future<void> fetchUsers() async {
    try {
      final apiService = ApiService();
      final data = await apiService.getContactList();
      print(" data 1234  $data");
      // Assuming API returns a List<Map<String, dynamic>>
      setState(() {
        contacts = (data as List).map((item) {
          return Contact(
            name: item['name'] ?? "No Name",
            accountName: item['accountName'] ?? "",
            email: item['email'] ?? "",
            phone: item['phone'] ?? "",
            title: item['title'] ?? "",
            imageUrl: item['imageUrl'] ?? "https://i.pravatar.cc/150?img=1",
          );
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contacts")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
          ? const Center(child: Text("No contacts found"))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(contact.imageUrl),
                      radius: 25,
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.email),
                        Text(contact.phone),
                        Text(contact.title),
                        Text(contact.accountName),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Calling ${contact.phone}"),
                              ),
                            );
                          },
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) async {
                            if (value == "View") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("View ${contact.name}")),
                              );
                            } else if (value == "Edit") {
                              final updatedContact = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditContactScreen(
                                    contact: {
                                      'name': contact.name,
                                      'accountName': contact.accountName,
                                      'email': contact.email,
                                      'phone': contact.phone,
                                      'title': contact.title,
                                      'imageUrl': contact.imageUrl,
                                    },
                                  ),
                                ),
                              );

                              if (updatedContact != null) {
                                setState(() {
                                  contacts[index] = updatedContact;
                                });
                              }
                            } else if (value == "Delete") {
                              final confirm = await CommonDialog.show(
                                context,
                                title:
                                    "Are you sure you want to delete ${contact.name}?",
                              );

                              if (confirm == true) {
                                setState(() {
                                  contacts.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("${contact.name} deleted"),
                                  ),
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: "View",
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text("View"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: "Edit",
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text("Edit"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: "Delete",
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text("Delete"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          final newContact = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditContactScreen(),
            ),
          );

          if (newContact != null) {
            setState(() {
              contacts.add(newContact);
            });
          }
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
