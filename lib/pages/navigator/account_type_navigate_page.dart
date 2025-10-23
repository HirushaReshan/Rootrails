// lib/pages/navigator/account_type_navigate_page.dart
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/type_selector.dart';

class AccountTypeNavigatePage extends StatelessWidget {
  const AccountTypeNavigatePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TypeSelector(
              text: 'User',
              onTap: () => Navigator.pushNamed(context, '/user_auth_page'),
            ),
            TypeSelector(
              text: 'Business',
              onTap: () => Navigator.pushNamed(context, '/business_register_page'),
            ),
          ]),
        ),
      ),
    );
  }
}
