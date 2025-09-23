import 'package:flutter/material.dart';

class LeadsPage extends StatelessWidget {
  const LeadsPage({super.key});

  final List<Map<String, String>> leads = const [
    {
      "name": "Rahul Test",
      "company": "Test",
      "email": "example@example.com",
      "source": "Advertisement",
    },
    {
      "name": "John Doe",
      "company": "Acme Inc",
      "email": "john.doe@example.com",
      "source": "Website",
    },
    {
      "name": "Jane Smith",
      "company": "GlobalTech",
      "email": "jane.smith@example.com",
      "source": "Referral",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // 🔹 Top Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16 ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Dropdown
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
                  onChanged: (value) {
                    // Handle filter change
                  },
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),

                // List icon
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.view_list, color: Colors.blue),
                ),

                // Map icon
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.map, color: Colors.blue),
                ),
              ],
            ),
          ),

          // 🔹 Lead List
          Expanded(
            child: ListView.separated(
              itemCount: leads.length,
              separatorBuilder: (context, index) =>  Padding(
      padding: EdgeInsets.symmetric(horizontal: 16), // 🔹 left & right padding
      child: Divider(
        height: 1,
        thickness: 0.8,
        color: Colors.grey[200],
      ),
    ),
              itemBuilder: (context, index) {
                final lead = leads[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.black54),
                      ),
                      const SizedBox(width: 12),

                      // Lead info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead["name"] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (lead["company"] != null)
                              Row(
                                children: [
                                  const Icon(Icons.business,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(lead["company"]!,
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                ],
                              ),
                            if (lead["email"] != null)
                              Row(
                                children: [
                                  const Icon(Icons.email,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(lead["email"]!,
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                ],
                              ),
                            if (lead["source"] != null)
                              Row(
                                children: [
                                  const Icon(Icons.source,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(lead["source"]!,
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                ],
                              ),
                          ],
                        ),
                      ),

                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // 🔹 Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new lead
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
