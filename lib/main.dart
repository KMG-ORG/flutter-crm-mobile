import 'package:crm_mobile/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/app_routes.dart';
import 'core/theme.dart';
import 'services/auth_service.dart';
import 'screens/home/home_page.dart';
import 'features/auth/login_page.dart';
import 'features/leads/lead_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService(),
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'LeadTrack App',
            // theme: AppTheme.lightTheme,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            initialRoute: auth.isAuthenticated
                ? AppRoutes.home
                : AppRoutes.login,
            routes: {
              AppRoutes.login: (context) => const LoginPage(),
              AppRoutes.home: (context) =>
                  const SplashScreen(), //const HomePage(),
              AppRoutes.leads: (context) => const LeadListPage(),
            },
          );
        },
      ),
    );
  }
}
