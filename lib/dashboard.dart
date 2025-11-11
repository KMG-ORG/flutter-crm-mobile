import 'package:flutter/material.dart';
import 'services/api_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isLoading = true;

  Map<String, dynamic>? crmDashboardData;
  Map<String, int>? dashboardCounts;
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// ✅ Load everything together (user, counts, dashboard)
  Future<void> _loadDashboardData() async {
    final api = ApiService();
    try {
      setState(() => isLoading = true);

      final results = await Future.wait([
        api.getUserDetails(),
        api.getTotalLead(),
        api.getOpenOpportunity(),
        api.getTotalOpenTicket(),
        api.getCrmDashboard(),
      ]);

      setState(() {
        userDetails = results[0] as Map<String, dynamic>?;
        dashboardCounts = {
          "leads": results[1] as int,
          "opportunities": results[2] as int,
          "tickets": results[3] as int,
        };
        crmDashboardData = results[4] as Map<String, dynamic>?;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error loading dashboard: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // ✅ Single global loader
      return const Center(child: CircularProgressIndicator());
    }

    final userName =
        userDetails?['display_name'] ??
        userDetails?['fullName'] ??
        userDetails?['name'] ??
        "User";

    final counts =
        dashboardCounts ?? {"leads": 0, "opportunities": 0, "tickets": 0};

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👋 Welcome Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Welcome $userName!",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
          ),

          // 📊 Stat Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard(
                    "Leads",
                    counts["leads"].toString(),
                    Icons.people_alt,
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    "Opportunities",
                    counts["opportunities"].toString(),
                    Icons.trending_up,
                    Colors.purple,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    "Tickets",
                    counts["tickets"].toString(),
                    Icons.receipt_long,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🧾 Info Boxes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildInfoBox(
                  "My Tickets",
                  Icons.receipt_long,
                  Colors.deepPurple,
                  crmDashboardData?["ticketThisWeek"] ??
                      crmDashboardData?["ticketToday"] ??
                      [],
                ),
                const SizedBox(height: 16),
                _buildInfoBox(
                  "Opportunity By Stages",
                  Icons.task_alt,
                  Colors.orange,
                  crmDashboardData?["opportunityStage"] ?? [],
                ),
                const SizedBox(height: 16),
                _buildInfoBox(
                  "Recent Opportunities",
                  Icons.check_circle,
                  Colors.green,
                  crmDashboardData?["opportunity"] ?? [],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📦 Stat Card Widget
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📦 Info Box Widget
  Widget _buildInfoBox(
    String title,
    IconData icon,
    Color color,
    List<dynamic> data,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            const SizedBox(height: 12),

            // --- Dynamic List ---
            if (data.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "No records available",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: data.take(3).map((item) {
                  if (title == "Recent Opportunities") {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item["name"] ?? "Unnamed"),
                      subtitle: Text(
                        item["accountName"] ?? "",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(
                        Icons.trending_up,
                        color: Colors.purple,
                      ),
                    );
                  } else if (title == "Opportunity By Stages") {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item["stageName"] ?? "Unknown Stage"),
                      trailing: Text(
                        item["stageCount"] ?? "0",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else if (title == "My Tickets") {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item["ticketTitle"] ?? "Ticket"),
                      subtitle: Text(
                        item["status"] ?? "Open",
                        style: const TextStyle(color: Colors.orange),
                      ),
                    );
                  }
                  return const SizedBox();
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
