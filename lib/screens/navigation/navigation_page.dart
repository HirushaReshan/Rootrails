import 'package:flutter/material.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
      body: const Center(
        child: Text(
          'Main navigation and map logic will go here.You can add route planning, nearby parks, and directions.',
        ),
      ),
    );
  }
}
