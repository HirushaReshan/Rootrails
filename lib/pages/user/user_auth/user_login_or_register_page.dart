// lib/pages/auth/user_login_or_register_page.dart
import 'package:flutter/material.dart';
import 'user_login_page.dart';
import 'user_register_page.dart';

class UserLoginOrRegisterPage extends StatefulWidget {
  const UserLoginOrRegisterPage({super.key});
  @override
  State<UserLoginOrRegisterPage> createState() =>
      _UserLoginOrRegisterPageState();
}

class _UserLoginOrRegisterPageState extends State<UserLoginOrRegisterPage> {
  bool showLogin = true;
  void toggle() => setState(() => showLogin = !showLogin);

  @override
  Widget build(BuildContext context) => showLogin
      ? UserLoginPage(onTap: toggle)
      : UserRegisterPage(onTap: toggle);
}
