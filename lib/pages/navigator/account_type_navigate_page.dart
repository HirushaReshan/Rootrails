import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/type_selector.dart';

class AccountTypeNavigatePage extends StatelessWidget {
  const AccountTypeNavigatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TypeSelector(
                text: 'User',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/user_auth_page');
                },
              ),
              TypeSelector(
                text: 'Business',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/business_auth_page');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
