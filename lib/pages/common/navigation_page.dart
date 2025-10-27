import 'package:flutter/material.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map & Navigation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Interactive Map & GPS Tracking',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const Text(
              'This page is reserved for future integration with map APIs (e.g., Google Maps) for driver/safari tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Placeholder action
              },
              icon: const Icon(Icons.add_road),
              label: const Text('Start Dummy Navigation'),
            ),
          ],
        ),
      ),
    );
  }
}