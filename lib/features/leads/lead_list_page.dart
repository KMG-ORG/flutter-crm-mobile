// import 'package:flutter/material.dart';
// import 'package:crmMobileUi/appDrawer.dart';
// import '../../services/api_service.dart';
// import '../../shared/app_header.dart';
// // import '../../widgets/app_footer.dart';
// // import '../../widgets/app_sidebar.dart';
// import '../../shared/bottomNav.dart';

// class LeadListPage extends StatefulWidget {
//   const LeadListPage({super.key});

//   @override
//   State<LeadListPage> createState() => _LeadListPageState();
// }

// class _LeadListPageState extends State<LeadListPage> {
//   int _selectedIndex = 0;
//   final ApiService _apiService = ApiService();
//   late Future<List<Map<String, dynamic>>> _leadsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _leadsFuture = _apiService.getLeads();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text("Leads")),
//       appBar: const PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: AppHeader(),
//       ),
//       drawer: AppDrawer(
//         onItemTapped: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//       bottomNavigationBar: BottomNav(
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _leadsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//           final leads = snapshot.data ?? [];
//           if (leads.isEmpty) {
//             return const Center(child: Text("No leads found"));
//           }
//           return ListView.separated(
//             itemCount: leads.length,
//             separatorBuilder: (_, __) => const Divider(),
//             itemBuilder: (context, index) {
//               final lead = leads[index];
//               return ListTile(
//                 leading: CircleAvatar(
//                   child: Text(
//                     (lead['fullName'] != null && lead['fullName'].isNotEmpty)
//                         ? lead['fullName'][0]
//                         : "?",
//                   ),
//                 ),
//                 title: Text(
//                   lead['displayName'] ?? lead['fullName'] ?? "No Name",
//                 ),
//                 subtitle: Text(lead['email'] ?? lead['secondaryEmail'] ?? ""),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:crmMobileUi/features/leads/add_lead_page.dart';
import 'package:crmMobileUi/features/leads/lead_view_page.dart';
import 'package:crmMobileUi/services/api_service.dart';
import 'package:flutter/material.dart';

class LeadListPage extends StatefulWidget {
  const LeadListPage({super.key});

  @override
  State<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends State<LeadListPage> {
  List<Map<String, dynamic>> leads = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchLeads();
  }

  Future<void> fetchLeads() async {
    try {
      final apiService = ApiService();
      final data = await apiService.getLeads();
      setState(() {
        leads = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // 🔹 Top Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Leads",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        "This Month",
                        style: TextStyle(color: Colors.black87),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Lead List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text("Error: $errorMessage"))
                : RefreshIndicator(
                    onRefresh: fetchLeads,
                    child: ListView.builder(
                      itemCount: leads.length,
                      itemBuilder: (context, index) {
                        final lead = leads[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LeadViewPage(leadData: lead),
                              ),
                            );
                          },
                          child: LeadCard(
                            name: lead["fullName"] ?? "Unknown",
                            company: lead["companyName"] ?? "N/A",
                            email: lead["email"] ?? "N/A",
                            contact: lead["contactName"] ?? "N/A",
                            tag: lead["leadSource"] ?? "Cold Call",
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),

      // 🔹 Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLeadPage()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 🔹 Lead Card Widget
class LeadCard extends StatelessWidget {
  final String name;
  final String company;
  final String email;
  final String contact;
  final String tag;

  const LeadCard({
    super.key,
    required this.name,
    required this.company,
    required this.email,
    required this.contact,
    required this.tag,
  });

  Color _getTagTextColor(String tag) {
    switch (tag.toLowerCase()) {
      case "advertisement":
        return Colors.deepPurple;
      case "seminar partner":
        return Colors.red;
      case "cold call":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagColor = _getTagTextColor(tag);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300, // ✅ Light gray border
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // Left section (Lead details)
            Expanded(
              child: Column(
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
                  Row(
                    children: [
                      const Icon(
                        Icons.business,
                        size: 16,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          company,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.email,
                        size: 16,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          email,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          contact,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(
                        0.1,
                      ), // light pastel background
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(color: tagColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Right section (Call button styled like image)
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.phone_outlined,
                  color: Colors.blueAccent,
                  size: 24,
                ),
                onPressed: () {
                  // Add your call action here
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
