import 'package:flutter/material.dart';
import 'homePage.dart'; // 👈 Replace with your actual home page import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade in animation
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Stay for 3 seconds then navigate
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          curve: Curves.easeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'LeadTrack',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.only(top: 4.0, right: 4.0),
              //   child: Text(
              //     'by KMG',
              //     style: TextStyle(
              //       color: Colors.white70,
              //       fontSize: 16,
              //       fontStyle: FontStyle.italic,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
