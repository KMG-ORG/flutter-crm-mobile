import 'package:crm_mobile/appDrawer.dart';
import 'package:crm_mobile/dashboard.dart';
import 'package:crm_mobile/leads.dart';
import 'package:crm_mobile/screens/profile/profile_page.dart';
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

  final List<Widget> _pages = [
    const Dashboard(),
    const LeadsPage(),
    const Center(child: Text("Contacts Page")),
    const Center(child: Text("Accounts Page")),
    const Center(child: Text("More Page")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      appBar: AppBar(
        title: const Text("Leads", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // 🔹 makes hamburger icon white
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        // 🔹 Blue Gradient Background
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF42A5F5), // lighter blue
                Color(0xFF1976D2), // darker blue
              ],
            ),
          ),
        ),
      ),

      // ✅ Drawer
      // drawer: AppDrawer(
      //   onItemTapped: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });
      //   },
      // ),
      drawer: ProfilePage(
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

      // ✅ Bottom Navigation
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

      // ✅ Body changes with selected tab
      body: _pages[_selectedIndex],
    );
  }
}
