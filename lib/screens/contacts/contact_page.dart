import 'package:crm_mobile/services/api_service.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  final VoidCallback onClose;
  const ContactsPage({super.key, required this.onClose});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Map<String, dynamic>> contacts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    try {
      final apiService = ApiService();
      final data = await apiService.getContacts();
      setState(() {
        contacts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Contacts",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        //leading: const Icon(Icons.arrow_back),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onClose,
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add_circle_outline),
        //     onPressed: () {},
        //   ),
        // ],
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5733C7), Color(0xFF9A24C3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // All Contacts Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "All Contacts",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Contacts List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text("Error: $errorMessage"))
                : RefreshIndicator(
                    onRefresh: fetchContacts, // optional refresh function
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return contactCard(
                          name: contact['fullName'] ?? "Unknown",
                          category: contact['account'] ?? "N/A",
                          email: contact['email'] ?? "N/A",
                          phone: contact['phone'] ?? "N/A",
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget contactCard({
    required String name,
    required String category,
    required String email,
    required String phone,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            // Main body column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (category.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.apartment_outlined,
                        size: 16,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                if (email.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Colors.purple),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.purple),
                    const SizedBox(width: 6),
                    Text(phone),
                  ],
                ),
              ],
            ),
            // Phone icon at center right
            Positioned(
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.blue),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
