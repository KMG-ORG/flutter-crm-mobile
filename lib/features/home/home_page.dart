import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/app_sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Dashboard')),
    Center(child: Text('Profile')),
    Center(child: Text('Settings')),
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppHeader(),
      ),
      drawer: const AppSidebar(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppFooter(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
