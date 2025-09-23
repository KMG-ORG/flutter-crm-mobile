import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(   // ✅ Vertical scrolling for whole dashboard
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Welcome Rahul Mondal!",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
            ),
          ),

          // Horizontal stat cards (keep scroll horizontal here)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard("Leads", "120", Icons.people_alt, Colors.blue),
                  const SizedBox(width: 12),
                  _buildStatCard("Contacts", "80", Icons.contact_page, Colors.green),
                  const SizedBox(width: 12),
                  _buildStatCard("Accounts", "45", Icons.account_balance, Colors.orange),
                  const SizedBox(width: 12),
                  _buildStatCard("Opportunities", "60", Icons.trending_up, Colors.purple),
                  const SizedBox(width: 12),
                  _buildStatCard("Tasks", "30", Icons.task, Colors.red),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 📌 Multiple ticket-style boxes stacked vertically
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildInfoBox("My Tickets", Icons.receipt_long, Colors.deepPurple),
                const SizedBox(height: 16),
                _buildInfoBox("Opportunity By Stages", Icons.task_alt, Colors.orange),
                const SizedBox(height: 16),
                _buildInfoBox("Recent Opportunities", Icons.check_circle, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Stat Cards
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Big Info Boxes (Tickets / Tasks / Approvals)
  Widget _buildInfoBox(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("NikonX"),
              subtitle: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 10),
                  const SizedBox(width: 4),
                  const Text("In Progress",
                      style: TextStyle(color: Colors.green)),
                ],
              ),
              trailing: const Text("09/15/2025",
                  style: TextStyle(color: Colors.grey)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("AlphaCam"),
              subtitle: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.orange, size: 10),
                  const SizedBox(width: 4),
                  const Text("Pending",
                      style: TextStyle(color: Colors.orange)),
                ],
              ),
              trailing: const Text("09/18/2025",
                  style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
