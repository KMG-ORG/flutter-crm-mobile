import 'package:crmMobileUi/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../../core/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  bool _initialized = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize MSAL safely
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = context.read<AuthService>();
      await authService.init();
      if (mounted) setState(() => _initialized = true);
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
      body: Stack(
        children: [
          // 🌈 Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B2FF7), Color(0xFF9A4DFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🌊 Wavy Bottom Layer
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: _WaveClipper(),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🧠 Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                child: !_initialized
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 🌟 Logo + tagline
                          Column(
                            children: const [
                              Text(
                                "LeadTrack",
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Powering Connections with Intelligence.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 45),

                          // ✨ Headline
                          const Text(
                            "Effortlessly Manage your\nTeam and Operations",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              height: 1.4,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),

                          const Text(
                            "Login to access your LeadTrack and manage your team",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // 📧 Email Input
                          // TextField(
                          //   controller: _emailController,
                          //   style: const TextStyle(color: Colors.white),
                          //   decoration: InputDecoration(
                          //     filled: true,
                          //     fillColor: Colors.white,
                          //     hintText: "Enter Email / Phone Number",
                          //     hintStyle: const TextStyle(color: Colors.white70),
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(14),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     contentPadding: const EdgeInsets.symmetric(
                          //       horizontal: 20,
                          //       vertical: 16,
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 20),

                          // 🔘 Continue Button
                          // Container(
                          //   width: double.infinity,
                          //   height: 52,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(14),
                          //     gradient: const LinearGradient(
                          //       colors: [
                          //         Color(0xFF5733C7),
                          //         Color(0xFF8D28C4)
                          //       ],
                          //       begin: Alignment.centerLeft,
                          //       end: Alignment.centerRight,
                          //     ),
                          //   ),
                          //   child: ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: Colors.transparent,
                          //       shadowColor: Colors.transparent,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(14),
                          //       ),
                          //     ),
                          //     onPressed: () {
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         const SnackBar(
                          //           content: Text(
                          //               "Continue button clicked (demo)"),
                          //         ),
                          //       );
                          //     },
                          //     child: const Text(
                          //       "Continue",
                          //       style: TextStyle(
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 20),

                          // 🪟 Microsoft Login
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              // icon: Image.network(
                              //   'https://upload.wikimedia.org/wikipedia/commons/4/44/Microsoft_logo.png',
                              //   height: 20,
                              // ),
                              label: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Login with Microsoft",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                              onPressed: _loading
                                  ? null
                                  : () async {
                                      setState(() => _loading = true);
                                      final result = await authService.login();
                                      final token = result['token'];
                                      final message =
                                          result['message'] ??
                                          "Unexpected error";

                                      if (token != null && token.isNotEmpty) {
                                        _saveToken(token);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Login failed. Try again.",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                            ),
                          ),

                          const SizedBox(height: 60),

                          // Footer
                          const Text(
                            "© 2025 Lead Track. All Rights Reserved.",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 Custom Wave Shape for bottom overlay
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.55,
      size.width * 0.5,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.25,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
