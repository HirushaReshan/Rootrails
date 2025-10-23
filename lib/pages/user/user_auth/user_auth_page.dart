import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/pages/user/user_auth/user_login_or_register_page.dart';
import 'package:rootrails/pages/user/user_pages/user_home_page.dart';

class UserAuthPage extends StatelessWidget {
  const UserAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return UserHomePage();
          } else {
            return UserLoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
