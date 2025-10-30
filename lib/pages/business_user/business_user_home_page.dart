import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/business.dart';
import 'package:rootrails/widgets/business_drawer.dart';
import 'dart:async'; // Required for StreamSubscription

// Import all pages used in the bottom navigation
import 'package:rootrails/pages/business_user/business_orders_page.dart';
import 'package:rootrails/pages/business_user/business_profile_page.dart';
import 'package:rootrails/pages/common/navigation_page.dart';

class BusinessUserHomePage extends StatefulWidget {
  const BusinessUserHomePage({super.key});

  @override
  State<BusinessUserHomePage> createState() => _BusinessUserHomePageState();
}

class _BusinessUserHomePageState extends State<BusinessUserHomePage> {
  int _selectedIndex = 0;
  Business? _businessProfile;
  bool _isLoading = true;
  StreamSubscription<DocumentSnapshot>? _profileSubscription;

  // Pages are defined here
  final List<Widget> _pages = [
    const BusinessOrdersPage(), // Index 0: Orders/Dashboard
    const NavigationPage(), // Index 1: Navigation (Map)
    const BusinessProfilePage(), // Index 2: Profile/Settings
  ];

  @override
  void initState() {
    super.initState();
    _setupProfileStream();
  }

  @override
  void dispose() {
    // IMPORTANT: Cancel the stream subscription to avoid memory leaks
    _profileSubscription?.cancel();
    super.dispose();
  }

  void _setupProfileStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    _profileSubscription?.cancel();

    // Listen to the 'drivers' collection for this user's profile
    _profileSubscription = FirebaseFirestore.instance
        .collection('drivers') // <-- FIX: Reads from 'drivers'
        .doc(user.uid)
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists) {
              setState(() {
                _businessProfile = Business.fromFirestore(doc);
                _isLoading = false;
              });
            } else {
              setState(() => _isLoading = false);
            }
          },
          onError: (error) {
            debugPrint("Error fetching business profile stream: $error");
            setState(() => _isLoading = false);
          },
        );
  }

  Future<void> _toggleServiceStatus(bool newValue) async {
    // Safety check
    if (_businessProfile == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('drivers') // <-- FIX: Writes to 'drivers'
          .doc(_businessProfile!.uid)
          .update({
            'is_open': newValue,
            'updated_at': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue ? 'Service is now ONLINE.' : 'Service is now OFFLINE.',
            ),
            backgroundColor: newValue ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String businessName =
        _businessProfile?.businessName ?? 'Safari Service';
    final String userEmail = _businessProfile?.email ?? 'N/A';
    final bool isOpen = _businessProfile?.isOpen ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Driver Dashboard' : businessName),
        actions: [
          // Online Status Toggle
          Row(
            children: [
              Text(
                isOpen ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(
                  color: isOpen ? Colors.greenAccent : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: isOpen,
                // FIX: Pass the function directly to make it clickable
                onChanged: _toggleServiceStatus,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      drawer: BusinessDrawer(businessName: businessName, userEmail: userEmail),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Route',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications),
            activeIcon: Icon(Icons.settings_applications_sharp),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
