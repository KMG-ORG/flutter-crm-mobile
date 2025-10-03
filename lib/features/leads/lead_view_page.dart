import 'package:flutter/material.dart';

class LeadViewPage extends StatefulWidget {
  final Map<String, dynamic> leadData; // 👈 data from previous page

  const LeadViewPage({Key? key, required this.leadData}) : super(key: key);

  @override
  State<LeadViewPage> createState() => _LeadViewPageState();
}

class _LeadViewPageState extends State<LeadViewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget buildSection(String title, {IconData icon = Icons.add}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Icon(icon, color: Colors.blue),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leads", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // <-- active tab text color
          unselectedLabelColor: Colors.white70, // <-- inactive tab text color
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "RELATED"),
            Tab(text: "EMAILS"),
            Tab(text: "DETAILS"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRelatedTab(), _buildEmailsTab(), _buildDetailsTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.email), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: ""),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildRelatedTab() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.leadData['fullName'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.leadData['email'] ?? 'No Email',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.leadData['phone'] ?? 'No Phone',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.leadData['owner'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Owner",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        buildSection("Notes", icon: Icons.text_snippet),
        buildSection("Attachments"),
        buildSection("Products"),
        buildSection("Open Tasks"),
        buildSection("Open Meetings"),
        buildSection("Open Calls"),
        buildSection("Closed Tasks"),
        buildSection("Closed Meetings"),
      ],
    ),
  );
}


  Widget _buildEmailsTab() {
    return const Center(child: Text("Emails Tab Content"));
  }

  Widget _buildDetailsTab() {
    return const Center(child: Text("Details Tab Content"));
  }
}
