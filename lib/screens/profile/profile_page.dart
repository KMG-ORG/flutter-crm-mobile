//import 'package:crmMobileUi/core/services/auth_service.dart';
import 'package:crmMobileUi/services/api_service.dart';
import 'package:crmMobileUi/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final Function(int) onItemTapped;

  const ProfilePage({super.key, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final apiService = ApiService();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: const Color.fromARGB(255, 109, 94, 180),
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A5AE0), Color(0xFFB35FE5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔹 Profile Card (Dynamic Data)
          FutureBuilder<Map<String, dynamic>?>(
            future: apiService
                .getUserDetails(), // ✅ Using the API service method
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("⚠️ Error loading user: ${snapshot.error}"),
                );
              }

              final user = snapshot.data;
              if (user == null) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No user data found"),
                );
              }

              // ✅ Adjust these keys according to your saved user data
              final userName =
                  user['display_name'] ??
                  user['fullName'] ??
                  user['username'] ??
                  'Unknown User';
              final email = user['email'] ?? 'Not Available';
              final roles = user['roles'] ?? [];
              final roleNames = (roles is List && roles.isNotEmpty)
                  ? roles
                        .map((r) => r['roleName'] ?? '')
                        .where((r) => r.toString().isNotEmpty)
                        .join(', ')
                  : 'User';

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
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
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.power_settings_new,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  await authService.logout();
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/login');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.email,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  email,
                                  style: const TextStyle(color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.work,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  roleNames,
                                  style: const TextStyle(color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 🔹 Menu List
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

// 🔹 Section Header Widget
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

// 🔹 Profile Menu Item Widget
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
