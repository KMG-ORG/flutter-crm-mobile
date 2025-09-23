import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: widget.onDestinationSelected,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: "Home"),
        NavigationDestination(icon: Icon(Icons.people_alt), label: "Leads"),
        NavigationDestination(icon: Icon(Icons.contact_page), label: "Contacts"),
        NavigationDestination(icon: Icon(Icons.account_balance), label: "Accounts"),
        NavigationDestination(icon: Icon(Icons.more), label: "More"),
      ],
    );
  }
}
