import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../services/auth_service.dart';

import '../../core/services/auth_service.dart';
// import '../../core/api/api_service.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _controller = TextEditingController();

//   void _saveToken() async {
//     final token = _controller.text.trim();
//     if (token.isNotEmpty) {
//       await context.read<AuthService>().saveToken(token);

//       // Navigate to home page
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, "/home");
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a valid token")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Enter Token")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: const InputDecoration(
//                 labelText: "Access Token",
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _saveToken,
//               child: const Text("Save Token"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /////////////////////

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Safe access to Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = context.read<AuthService>();
      await authService.init();
      if (mounted) {
        setState(() => _initialized = true);
      }
    });
  }

  void _saveToken(String token) {
    if (token.isNotEmpty) {
      final authService = context.read<AuthService>();
      authService.saveToken(token);
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid token")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      body: Center(
        child: !_initialized
            ? const CircularProgressIndicator()
            : _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  setState(() => _loading = true);
                  final token = await authService.login();
                  setState(() => _loading = false);

                  if (token != null && token.isNotEmpty) {
                    _saveToken(token);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login failed")),
                    );
                  }
                },
                child: const Text("Login with Azure"),
              ),
      ),
    );
  }
}

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   // final AuthService _authService = AuthService();
//   // final ApiService _apiService = ApiService();
//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     _authService.init(); // Initialize MSAL
//   }

//   void _saveToken(token) {
//     if (token.isNotEmpty) {
//       context.read<AuthService>().saveToken(token);

//       // Navigate to home page
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, "/home");
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a valid token")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: _loading
//             ? CircularProgressIndicator()
//             : ElevatedButton(
//                 child: Text('Login with Azure'),
//                 onPressed: () async {
//                   setState(() => _loading = true);
//                   final token = await _authService.login();
//                   setState(() => _loading = false);

//                   if (token != null) {
//                     _saveToken(token);
//                     // _apiService.setToken(token);
//                     // Navigator.pushReplacement(
//                     //   context,
//                     //   MaterialPageRoute(builder: (_) => DashboardPage()),
//                     // );
//                   } else {
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text('Login failed')));
//                   }
//                 },
//               ),
//       ),
//     );
//   }
// }
