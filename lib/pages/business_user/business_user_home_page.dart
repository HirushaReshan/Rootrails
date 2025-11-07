import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Import CurvedNavigationBar
import 'package:rootrails/models/business.dart';
import 'package:rootrails/pages/general_user/map_page.dart';
import 'package:rootrails/widgets/business_drawer.dart';
import 'dart:async';

// Import all pages used in the bottom navigation
import 'package:rootrails/pages/business_user/business_orders_page.dart';
import 'package:rootrails/pages/business_user/business_profile_page.dart';
import 'package:rootrails/pages/common/navigation_page.dart';

// Define the custom colors used for consistency
const Color kPrimaryGreen = Color(0xFF4C7D4D);
const Color kOrangeAccent = Color(0xFFFFA500);

// GlobalKey for Scaffold for drawer access
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// GlobalKey for CurvedNavigationBar
final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

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
    const MapPage(), // Index 1: Navigation (Map)
    const BusinessProfilePage(), // Index 2: Profile/Settings
  ];

  // Define the list of icons for the CurvedNavigationBar (3 items for business user)
  final List<Widget> _icons = const [
    Icon(Icons.dashboard, size: 30, color: Colors.white), // Orders/Dashboard
    Icon(Icons.map, size: 30, color: Colors.white), // Route
    Icon(Icons.person, size: 30, color: Colors.white), // Profile
  ];

  @override
  void initState() {
    super.initState();
    _setupProfileStream();
  }

  @override
  void dispose() {
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

    _profileSubscription = FirebaseFirestore.instance
        .collection('drivers')
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
    if (_businessProfile == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('drivers')
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
      key: _scaffoldKey, // Attach the global key for drawer access

      drawer: Drawer(
        semanticLabel: 'Business Menu',
        child: BusinessDrawer(businessName: businessName, userEmail: userEmail),
      ),

      // --- Custom AppBar Implementation (Latest Design) ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95.0),
        child: Container(
          margin: const EdgeInsets.only(top: 35.0, left: 15.0, right: 15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Left Side: Custom Menu/Drawer Icon
                IconButton(
                  icon: const Icon(Icons.menu, size: 30, color: kPrimaryGreen),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                // 2. Center: Branded RooTrails Title
                Row(
                  children: const [
                    Text(
                      'Roo',
                      style: TextStyle(
                        color: kOrangeAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Trails',
                      style: TextStyle(
                        color: kPrimaryGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // 3. Right Side: Status Toggle (Integrated from original AppBar actions)
                Row(
                  children: [
                    Text(
                      isOpen ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        color: isOpen
                            ? kPrimaryGreen
                            : Colors.red, // Use primary green for ON status
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Switch(
                      value: isOpen,
                      onChanged: _toggleServiceStatus,
                      activeColor: kPrimaryGreen,
                      inactiveThumbColor: Colors.red,
                      inactiveTrackColor: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // --- End Custom AppBar Implementation ---
      body: _pages[_selectedIndex],

      // --- Curved Navigation Bar Implementation (Latest Design) ---
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _selectedIndex,
        height: 60.0,
        items: _icons,
        color: kPrimaryGreen, // Color of the navigation bar background
        buttonBackgroundColor:
            kPrimaryGreen, // Color of the central item button
        backgroundColor: Colors.transparent, // Background color behind the bar
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: _onItemTapped,
        letIndexChange: (index) => true,
      ),
      // --- End Curved Navigation Bar Implementation ---
    );
  }
}
