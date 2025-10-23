// lib/pages/main/splash_router.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/widgets/business_bottom_nav.dart';
import 'package:rootrails/widgets/user_bottom_nav.dart';
import '../pages/auth/login_page.dart';

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});
  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        if (mounted)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        return;
      }
      final uid = user.uid;
      // Check if business exists
      final businessDoc = await _db.collection('Business_Users').doc(uid).get();
      if (businessDoc.exists) {
        if (mounted)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BusinessBottomNav(businessId: uid),
            ),
          );
        return;
      }
      // default to user
      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserBottomNav()),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
