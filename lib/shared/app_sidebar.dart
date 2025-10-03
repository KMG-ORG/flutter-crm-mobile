import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../core/app_routes.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(auth.user?['name'] ?? 'Guest'),
              accountEmail: Text(auth.user?['email'] ?? ''),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  (auth.user?['name']?.substring(0, 1) ?? 'G').toUpperCase(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRoutes.profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard),
              title: const Text('Leads'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRoutes.leads);
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await Provider.of<AuthService>(
                    context,
                    listen: false,
                  ).signOut();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
