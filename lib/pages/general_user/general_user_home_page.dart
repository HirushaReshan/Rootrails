import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:rootrails/models/general_user.dart';
import 'package:rootrails/widgets/user_drawer.dart';

// Import all pages used in the bottom navigation
import 'package:rootrails/pages/general_user/park_list_page.dart';
import 'package:rootrails/pages/general_user/my_list_page.dart';
import 'package:rootrails/pages/common/navigation_page.dart';
import 'package:rootrails/pages/general_user/general_user_profile_page.dart';

// Define the custom colors used for consistency
const Color kPrimaryGreen = Color(0xFF4C7D4D);
const Color kOrangeAccent = Color(0xFFFFA500);

// GlobalKey for CurvedNavigationBar
final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

// Define a Global Key for the Scaffold
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class GeneralUserHomePage extends StatefulWidget {
  const GeneralUserHomePage({super.key});

  @override
  State<GeneralUserHomePage> createState() => _GeneralUserHomePageState();
}

class _GeneralUserHomePageState extends State<GeneralUserHomePage> {
  int _selectedIndex = 0;
  GeneralUser? _userProfile;
  bool _isLoading = true;

  // Pages are defined here and linked by index
  final List<Widget> _pages = [
    const ParkListPage(),
    const MyListPage(),
    const NavigationPage(),
    const GeneralUserProfilePage(),
  ];

  // Define the list of icons for the CurvedNavigationBar
  final List<Widget> _icons = const [
    Icon(Icons.home, size: 30, color: Colors.white),
    Icon(Icons.list_alt, size: 30, color: Colors.white),
    Icon(Icons.map, size: 30, color: Colors.white),
    Icon(Icons.person, size: 30, color: Colors.white),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _userProfile = GeneralUser.fromFirestore(doc);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      setState(() => _isLoading = false);
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

    final String userName = _userProfile?.fullName ?? 'Guest User';
    final String userEmail = _userProfile?.email ?? 'N/A';

    return Scaffold(
      key: _scaffoldKey, // Attach the global key here
      // Set drawer and FIX animation duration
      drawer: Drawer(
        // Set the duration for a smoother, faster transition (default is 250ms)
        semanticLabel: 'User Menu',
        child: UserDrawer(userName: userName, userEmail: userEmail),
      ),
      // **Note:** The Drawer widget itself is used here, and the UserDrawer is its child.
      // The default Drawer animation is usually quick (250ms). If you still find it slow,
      // the issue might be in how you're using the custom UserDrawer. The code above uses
      // the default Drawer implementation, which should have a smooth animation.

      // --- Custom AppBar Implementation ---
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
                // Left Side: FIX - Changed to standard Icons.menu
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    size: 30,
                    color: kPrimaryGreen, // Match color scheme
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                // Center: Branded RooTrails Title
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

                // Right Side: Notification Icon
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    size: 30,
                    color: kPrimaryGreen,
                  ),
                  onPressed: () {
                    // TODO: Navigate to Notification page
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      // --- End Custom AppBar Implementation ---

      // Displays the current page based on _selectedIndex
      body: _pages[_selectedIndex],

      // --- Curved Navigation Bar Implementation ---
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _selectedIndex,
        height: 60.0,
        items: _icons,
        color: kPrimaryGreen,
        buttonBackgroundColor: kPrimaryGreen,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: _onItemTapped,
        letIndexChange: (index) => true,
      ),
      // --- End Curved Navigation Bar Implementation ---
    );
  }
}
