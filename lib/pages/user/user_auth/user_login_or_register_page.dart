import 'package:flutter/material.dart';
import 'package:rootrails/pages/user/user_auth/user_login_page.dart';
import 'package:rootrails/pages/user/user_auth/user_register_page.dart';


class UserLoginOrRegisterPage extends StatefulWidget {
  const UserLoginOrRegisterPage({super.key});

  @override
  State<UserLoginOrRegisterPage> createState() => _UserLoginOrRegisterPageState();
}

class _UserLoginOrRegisterPageState extends State<UserLoginOrRegisterPage> {

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
      return UserLoginPage(
        onTap: togglePages);
    } else {
      return UserRegisterPage(
        onTap: togglePages,
      );
    }
  }
}