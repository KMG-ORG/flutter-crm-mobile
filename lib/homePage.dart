import 'package:crm_mobile/dashboard.dart';
import 'package:crm_mobile/features/leads/lead_list_page.dart';
import 'package:crm_mobile/screens/contacts/contact_page.dart';
import 'package:crm_mobile/screens/account/account_page.dart';
import 'package:crm_mobile/screens/profile/profile_page.dart';
import 'package:crm_mobile/screens/more/more_page.dart';
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
        setState(() {
          _selectedIndex = 0; // go back to Home
        });
      },
    ),

    AccountsPage(
      onClose: () {
        setState(() {
          _selectedIndex = 0; // go back to Home
        });
      },
    ),

    MorePage(
      onClose: () {
        setState(() {
          _selectedIndex = 0; // go back to Home
        });
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
              title: _selectedIndex == 0
                  ? Row(
                      children: [
                        // 🔹 Avatar + "Hi Erin!" only for Dashboard
                        GestureDetector(
                          onTap: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage(
                              "assets/images/profile.jpg",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Hi Erin!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _getTitleForIndex(_selectedIndex),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
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
