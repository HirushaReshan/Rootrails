// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/splash_route.dart';
import 'package:rootrails/widgets/business_bottom_nav.dart';
import 'package:rootrails/widgets/user_bottom_nav.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/user_register_page.dart';
import 'pages/auth/business_register_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RootRailsApp());
}

class RootRailsApp extends StatelessWidget {
  const RootRailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RootRails',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashRouter(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register_user': (_) => const UserRegisterPage(),
        '/register_business': (_) => const BusinessRegisterPage(),
        '/user_home': (_) => const UserBottomNav(),
        '/business_home': (_) => const BusinessBottomNav(),
      },
    );
  }
}
