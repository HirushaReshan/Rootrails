import 'package:flutter/material.dart';

import 'package:rootrails/pages/business/business_auth/business_login_page.dart';
import 'package:rootrails/pages/business/business_auth/business_register_page.dart';


class BusinessLoginOrRegisterPage extends StatefulWidget {
  const BusinessLoginOrRegisterPage({super.key});

  @override
  State<BusinessLoginOrRegisterPage> createState() => _BusinessLoginOrRegisterPageState();
}

class _BusinessLoginOrRegisterPageState extends State<BusinessLoginOrRegisterPage> {

  //show login page first
  bool showLoginPage = true;

  //toggle between login and ResgisterPage
  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage){
      return BusinessLoginPage(
        onTap: togglePages);
    } else {
      return BusinessRegisterPage(
        onTap: togglePages,
      );
    }
  }
}