import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
// Import your firebase_options.dart file where Firebase is configured
// import 'firebase_options.dart';

import 'theme/app_themes.dart';
import 'pages/common/start_page.dart';
import 'pages/general_user/general_user_home_page.dart'; // Will be created later

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Assume you have your firebase_options.dart configured
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // Placeholder init for simplicity:
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(create: (_) => ThemeService(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Safari Booking App',
          debugShowCheckedModeBanner: false,
          theme: themeService.themeData,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // This stream listens to the Firebase Auth state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while connecting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user is logged in
        if (snapshot.hasData) {
          // TODO: Implement logic to check if user is General or Business.
          // For now, we'll assume logged-in users go to the General User Home Page.
          return const GeneralUserHomePage();
        }

        // If no user is logged in, start the app flow
        return const StartPage();
      },
    );
  }
}
