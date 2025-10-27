import 'dart:async';
import 'package:flutter/material.dart';
import 'role_selection_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start animation and timer
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          curve: Curves.easeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder for the App Logo/Animation
              Icon(
                Icons.directions_car_filled,
                size: 100,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 20),
              Text(
                'SafariGo',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(3.0, 3.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your Wild Adventure Awaits',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
