// lib/pages/business/business_pages/business_home_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/drawer/business_drawer.dart';
import 'package:rootrails/pages/business/business_pages/business_mylist_page.dart';
import 'package:rootrails/pages/business/business_pages/business_orders_page.dart';
import 'package:rootrails/pages/business/business_pages/business_settings_page.dart';

class BusinessHomePage extends StatefulWidget {
  const BusinessHomePage({super.key});

  @override
  State<BusinessHomePage> createState() => _BusinessHomePageState();
}

class _BusinessHomePageState extends State<BusinessHomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // React to auth changes so the page updates when user signs in/out
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        // If not signed in show a small guest view prompting sign in
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Business')),
            drawer: const BusinessDrawer(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'You are not signed in as a business.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please sign in to view business dashboard, requests and earnings.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        // If you have a dedicated auth route, navigate there.
                        // Otherwise you can navigate back to the selector/login screen:
                        Navigator.pushNamed(context, '/business_auth_page');
                      },
                      child: const Text('Sign in / Register'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // If signed in, show the normal business UI
        final pages = [
          _dashboard(user),
          const BusinessMyListPage(),
          const BusinessOrdersPage(),
          const BusinessSettingsPage(),
        ];

        return Scaffold(
          appBar: AppBar(title: Text('Business: ${user.email ?? ''}')),
          drawer: const BusinessDrawer(),
          body: pages[_index],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My List'),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dashboard(User user) {
    // you can fetch earnings / counts here using the user's uid when needed
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Business dashboard for ${user.email}\n\nPending requests & earnings summary will show here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
