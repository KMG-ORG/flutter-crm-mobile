import 'package:crm_mobile/features/leads/add_lead_page.dart';
import 'package:crm_mobile/features/leads/lead_view_page.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart'; // ✅ Import your API service

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
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
          // 🔹 Top Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: "All Leads",
                  items: const [
                    DropdownMenuItem(
                      value: "All Leads",
                      child: Text("All Leads"),
                    ),
                    DropdownMenuItem(
                      value: "My Leads",
                      child: Text("My Leads"),
                    ),
                    DropdownMenuItem(
                      value: "Converted",
                      child: Text("Converted"),
                    ),
                  ],
                  onChanged: (value) {},
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.view_list, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.map, color: Colors.blue),
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
                    child: ListView.separated(
                      itemCount: leads.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 1,
                          thickness: 0.8,
                          color: Colors.grey[200],
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final lead = leads[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeadViewPage(
                                  leadData:
                                      lead, // ✅ Pass the lead object to the next page
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.grey[300],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // 🧠 Lead Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ✅ Full Name
                                      Text(
                                        lead["fullName"] ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),

                                      // ✅ Company Name
                                      if (lead["companyName"] != null)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.business,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                lead["companyName"] ?? "",
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),

                                      // ✅ Email
                                      if (lead["email"] != null)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.email,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                lead["email"] ?? "",
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),

                                      // ✅ Source
                                      if (lead["leadSource"] != null)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.source,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                lead["leadSource"] ?? "",
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
      MaterialPageRoute(
        builder: (context) => const AddLeadPage(),
      ),
    );
  },
  backgroundColor: Colors.blue,
  child: const Icon(Icons.add),
),
    );
  }
}
