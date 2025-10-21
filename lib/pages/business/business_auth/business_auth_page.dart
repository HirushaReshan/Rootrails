import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/pages/business/business_pages/business_home_page.dart';
import 'business_login_or_register_page.dart';

class BusinessAuthPage extends StatelessWidget {
  const BusinessAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            return BusinessHomePage();
          }

          else{
            return BusinessLoginOrRegisterPage();
          }
        },
        ),
    );
  }
}