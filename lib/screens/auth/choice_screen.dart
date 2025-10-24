import 'package:flutter/material.dart';
import 'general/login_page.dart';
import 'business/business_login.dart';

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Are you a General user or a Business?',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeneralLogin()),
                ),
                child: const Text('General User'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BusinessLogin()),
                ),
                child: const Text('Business / Driver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
