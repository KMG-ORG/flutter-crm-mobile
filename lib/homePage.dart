import 'package:crmMobileUi/dashboard.dart';
import 'package:crmMobileUi/features/leads/lead_list_page.dart';
import 'package:crmMobileUi/screens/contacts/contact_page.dart';
import 'package:crmMobileUi/screens/account/account_page.dart';
import 'package:crmMobileUi/screens/profile/profile_page.dart';
import 'package:crmMobileUi/screens/more/more_page.dart';
import 'package:crmMobileUi/services/api_service.dart';
import 'package:flutter/material.dart';
import 'shared/bottomNav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        const Dashboard(),
        const LeadListPage(),
        ContactsPage(
          onClose: () {
            setState(() => _selectedIndex = 0);
          },
        ),
        AccountsPage(
          onClose: () {
            setState(() => _selectedIndex = 0);
          },
        ),
        MorePage(
          onClose: () {
            setState(() => _selectedIndex = 0);
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _selectedIndex != 0
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: FutureBuilder<Map<String, dynamic>?>(
                future: ApiService().getUserDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      "Hi...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }

                  final user = snapshot.data ?? {};
                  final userName = user['display_name'] ??
                      user['fullName'] ??
                      user['name'] ??
                      "User";

                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.deepPurple[300],
                          child: Text(
                            (() {
                              final displayName = userName.trim();
                              if (displayName.isEmpty) return '';
                              final parts = displayName.split(' ');
                              if (parts.length == 1) {
                                return parts.first.substring(0, 1).toUpperCase();
                              } else {
                                return (parts.first[0] + parts.last[0])
                                    .toUpperCase();
                              }
                            })(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Hi, $userName!",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
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
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF5733C7), Color(0xFF9A24C3)],
                  ),
                ),
              ),
            ),

      drawer: ProfilePage(
        onItemTapped: (index) {
          setState(() => _selectedIndex = index);
        },
      ),

      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),

      body: _pages[_selectedIndex],
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return "Dashboard";
      case 1:
        return "Leads";
      case 2:
        return "Contacts";
      case 3:
        return "";
      default:
        return "";
    }
  }
}
