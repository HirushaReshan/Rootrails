import 'package:flutter/material.dart';
import 'package:rootrails/pages/business/business_auth/business_login_page.dart';
import 'package:rootrails/pages/business/business_auth/business_register_page.dart';

class BusinessLoginOrRegisterPage extends StatefulWidget {
  const BusinessLoginOrRegisterPage({super.key});

  @override
  State<BusinessLoginOrRegisterPage> createState() =>
      _BusinessLoginOrRegisterPageState();
}

class _BusinessLoginOrRegisterPageState
    extends State<BusinessLoginOrRegisterPage> {
  bool showLogin = true;

  void toggle() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLogin
        ? BusinessLoginPage(onTap: toggle)
        : BusinessRegisterPage(onTap: toggle);
  }
}
