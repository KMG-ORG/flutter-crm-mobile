import 'package:flutter/material.dart';
import 'package:crm_mobile/appDrawer.dart';
import '../../services/api_service.dart';
import '../../widgets/app_header.dart';
// import '../../widgets/app_footer.dart';
// import '../../widgets/app_sidebar.dart';
import '../../bottomNav.dart';

class LeadListPage extends StatefulWidget {
  const LeadListPage({super.key});

  @override
  State<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends State<LeadListPage> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _leadsFuture;

  @override
  void initState() {
    super.initState();
    _leadsFuture = _apiService.getLeads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Leads")),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppHeader(),
      ),
      drawer: AppDrawer(
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _leadsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final leads = snapshot.data ?? [];
          if (leads.isEmpty) {
            return const Center(child: Text("No leads found"));
          }
          return ListView.separated(
            itemCount: leads.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final lead = leads[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    (lead['fullName'] != null && lead['fullName'].isNotEmpty)
                        ? lead['fullName'][0]
                        : "?",
                  ),
                ),
                title: Text(
                  lead['displayName'] ?? lead['fullName'] ?? "No Name",
                ),
                subtitle: Text(lead['email'] ?? lead['secondaryEmail'] ?? ""),
              );
            },
          );
        },
      ),
    );
  }
}
