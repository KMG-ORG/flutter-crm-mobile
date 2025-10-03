import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Function(int) onItemTapped;

  const ProfilePage({super.key, required this.onItemTapped});
  //const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // AppBar with Gradient
          Container(
            padding: const EdgeInsets.only(
              top: 15,
              left: 16,
              right: 16,
              bottom: 15,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A5AE0), Color(0xFFB35FE5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Spacer(),
                const Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),

          // Profile Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              //color: Colors.pink[50],
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  // backgroundImage: NetworkImage(
                  //   "https://randomuser.me/api/portraits/women/44.jpg",
                  // ),
                  backgroundImage: AssetImage("images/sidemenu/profile.jpg"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Erin Mitchell",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "erinMitchell@company.com",
                        style: TextStyle(color: Colors.black54),
                      ),
                      SizedBox(height: 4),
                      Text("Admin", style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.power_settings_new,
                    color: Colors.red,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SectionHeader(title: "Custom Settings"),
                ProfileMenuItem(
                  icon: Icons.insert_drive_file,
                  text: "Template",
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.notifications_active,
                  text: "Notification Configuration",
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.picture_as_pdf,
                  text: "Demo PPT",
                  onTap: () {},
                ),
                const SizedBox(height: 12),

                const SectionHeader(title: "Identity"),
                ProfileMenuItem(
                  icon: Icons.flash_on,
                  text: "Action Permission",
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.dashboard_customize,
                  text: "UI Permission",
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.supervised_user_circle,
                  text: "User Management",
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.work,
                  text: "Role Management",
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.show_chart,
                  text: "User Activity",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Section Header
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }
}

// Menu Item Widget
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.purple),
      ),
      title: Text(text, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
    );
  }
}
