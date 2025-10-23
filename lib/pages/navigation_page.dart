import 'package:flutter/material.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 500,
          width: 500,
          color: Colors.white,
          child: Text(
            'Navigation Page',
            style: TextStyle(
              color: Colors.grey.shade300
            ),
          ),
        ),
      ),
    );
  }
}