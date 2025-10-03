import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class UserInfoAction extends StatelessWidget {
  const UserInfoAction({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    final displayName = auth.user?['displayName'] ?? "User";
    final email = auth.user?['mail'] ?? auth.user?['userPrincipalName'] ?? "";

    return PopupMenuButton<String>(
      icon: const CircleAvatar(child: Icon(Icons.person)),
      onSelected: (value) async {
        if (value == 'logout') {
          await auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                email,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18),
              SizedBox(width: 8),
              Text("Logout"),
            ],
          ),
        ),
      ],
    );
  }
}
