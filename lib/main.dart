import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
// Make sure you have your firebase_options.dart file from your Firebase setup
// import 'firebase_options.dart'; 

import 'theme/app_themes.dart';
import 'pages/common/start_page.dart';
import 'pages/general_user/general_user_home_page.dart';
import 'pages/business_user/business_user_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure you have this file and uncomment the line
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // ); 
  
  // Placeholder for running without firebase_options.dart
  await Firebase.initializeApp(); 
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'SafariGo',
          debugShowCheckedModeBanner: false,
          theme: themeService.themeData,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

// This wrapper checks auth state and then checks the user's role
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If user is logged in
        if (snapshot.hasData) {
          // Check their role from Firestore
          return RoleCheckWrapper(user: snapshot.data!);
        }

        // If no user, show the Start Page (intro animation)
        return const StartPage();
      },
    );
  }
}

// This widget checks the role of the logged-in user
class RoleCheckWrapper extends StatelessWidget {
  final User user;
  const RoleCheckWrapper({super.key, required this.user});

  Future<String?> _getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final role = snapshot.data;
          // Route based on role
          if (role == 'business_user') {
            return const BusinessUserHomePage();
          }
          if (role == 'general_user') {
            return const GeneralUserHomePage();
          }
        }
        
        // If role is not found or error, default to General User Home
        // This handles cases like Google Sign-In where role might not be set yet
        // or if the user document is corrupted.
        // A better app might show an error page or force role selection.
        return const GeneralUserHomePage();
      },
    );
  }
}/*  */