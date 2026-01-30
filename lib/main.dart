import 'package:flutter/material.dart';
import 'core/core.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/home/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoamlyApp());
}

/// Main application widget for Roamly
class RoamlyApp extends StatelessWidget {
  const RoamlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        // Additional routes will be added as features are built:
        // '/login': (context) => const LoginScreen(),
        // '/register': (context) => const RegisterScreen(),
        // '/profile': (context) => const ProfileScreen(),
        // '/trips': (context) => const TripsScreen(),
        // '/community': (context) => const CommunityScreen(),
      },
    );
  }
}
