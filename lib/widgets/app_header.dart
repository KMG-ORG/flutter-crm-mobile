// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/auth_service.dart';

// class AppHeader extends StatelessWidget implements PreferredSizeWidget {
//   const AppHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthService>(context);

//     return AppBar(
//       title: const Text('LeadTrack App'),
//       actions: [
//         if (auth.user != null) ...[
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Center(
//               child: Text(
//                 auth.user?['displayName'] ?? '',
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//         IconButton(
//           icon: const Icon(Icons.logout),
//           onPressed: () async {
//             await auth.signOut();
//             Navigator.pushReplacementNamed(context, '/login');
//           },
//         ),
//       ],
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
import 'package:flutter/material.dart';
import 'user_info_action.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('LeadTrack App'),
      actions: const [UserInfoAction()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
