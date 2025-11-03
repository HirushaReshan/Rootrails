import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:rootrails/models/business.dart';
import 'package:rootrails/widgets/business_drawer.dart';
import 'dart:async';

import 'package:rootrails/pages/business_user/business_orders_page.dart';
import 'package:rootrails/pages/business_user/business_profile_page.dart';
import 'package:rootrails/pages/common/navigation_page.dart';

const Color kPrimaryGreen = Color(0xFF4C7D4D);
const Color kOrangeAccent = Color(0xFFFFA500);

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    const BusinessOrdersPage(), // Index 0
    const NavigationPage(), // Index 1
    const BusinessProfilePage(), // Index 2
  ];

  // Define the list of icons for the CurvedNavigationBar
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
                //Drawer Icon
                IconButton(
                  icon: const Icon(Icons.menu, size: 30, color: kPrimaryGreen),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                //RooTrails Title
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

                //Status Toggle
                Row(
                  children: [
                    Text(
                      isOpen ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        color: isOpen
                            ? kPrimaryGreen
                            : Colors.red, //ON status
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

      body: _pages[_selectedIndex],

      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _selectedIndex,
        height: 60.0,
        items: _icons,
        color: kPrimaryGreen,
        buttonBackgroundColor:
            kPrimaryGreen, 
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: _onItemTapped,
        letIndexChange: (index) => true,
      ),
      
    );
  }
}
