import 'package:crmMobileUi/core/services/auth_service.dart';
import 'package:crmMobileUi/features/leads/lead_list_page.dart';
import 'package:crmMobileUi/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/app_routes.dart';
import 'core/theme.dart';
// import 'services/auth_service.dart';
import 'screens/home/home_page.dart';
import 'features/auth/login_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<AuthService>(
//       create: (_) => AuthService(),
//       child: Consumer<AuthService>(
//         builder: (context, auth, _) {
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             title: 'LeadTrack App',
//             // theme: AppTheme.lightTheme,
//             theme: ThemeData(
//               colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//             ),
//             initialRoute: auth.isAuthenticated
//                 ? AppRoutes.home
//                 : AppRoutes.login,
//             routes: {
//               AppRoutes.login: (context) => const LoginPage(),
//               AppRoutes.home: (context) =>
//                   const SplashScreen(), //const HomePage(),
//               AppRoutes.leads: (context) => const LeadListPage(),
//             },
//           );
//         },
//       ),
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Wrap the entire app with ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(create: (_) => AuthService(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access AuthService safely here
    final auth = context.watch<AuthService>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LeadTrack App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: auth.isAuthenticated ? const SplashScreen() : const LoginPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case AppRoutes.leads:
            return MaterialPageRoute(builder: (_) => const LeadListPage());
          default:
            return null;
        }
      },
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<AuthService>(
//       create: (_) => AuthService(),
//       child: Consumer<AuthService>(
//         builder: (context, auth, _) {
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             title: 'LeadTrack App',
//             theme: ThemeData(
//               colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//             ),
//             home: auth.isAuthenticated
//                 ? const SplashScreen()
//                 : const LoginPage(),
//             onGenerateRoute: (settings) {
//               // Use builder so context is under Provider
//               switch (settings.name) {
//                 case AppRoutes.login:
//                   return MaterialPageRoute(
//                     builder: (context) => const LoginPage(),
//                   );
//                 case AppRoutes.home:
//                   return MaterialPageRoute(
//                     builder: (context) => const SplashScreen(),
//                   );
//                 case AppRoutes.leads:
//                   return MaterialPageRoute(
//                     builder: (context) => const LeadListPage(),
//                   );
//                 default:
//                   return null;
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
// }
