import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/pages/business/business_auth/business_login_or_register_page.dart';
import 'package:rootrails/pages/business/business_pages/business_home_page.dart';

class BusinessAuthPage extends StatelessWidget {
  const BusinessAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading indicator while waiting for Firebase response
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If user is logged in, go to home page
          if (snapshot.hasData) {
            return const BusinessHomePage();
          }

          // Otherwise, show login/register page
          return const BusinessLoginOrRegisterPage();
        },
      ),
    );
  }
}
