import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/general_user.dart';
import 'package:rootrails/widgets/user_drawer.dart';

// Import all pages used in the bottom navigation
import 'package:rootrails/pages/general_user/park_list_page.dart';
import 'package:rootrails/pages/general_user/my_list_page.dart';
import 'package:rootrails/pages/common/navigation_page.dart';
import 'package:rootrails/pages/general_user/general_user_profile_page.dart';

class GeneralUserHomePage extends StatefulWidget {
  const GeneralUserHomePage({super.key});

  @override
  State<GeneralUserHomePage> createState() => _GeneralUserHomePageState();
}

class _GeneralUserHomePageState extends State<GeneralUserHomePage> {
  int _selectedIndex = 0;
  GeneralUser? _userProfile;
  bool _isLoading = true;

  // Pages are defined here and linked by index to the BottomNavigationBar
  final List<Widget> _pages = [
    const ParkListPage(), // Index 0: Home/Parks
    const MyListPage(), // Index 1: My List/Bookings
    const NavigationPage(), // Index 2: Navigation (Map)
    const GeneralUserProfilePage(), // Index 3: Profile
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
      appBar: AppBar(
        title: const Text('Safari Booker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // TODO: Notification page
            },
          ),
        ],
      ),
      // Use the UserDrawer for the General User
      drawer: UserDrawer(userName: userName, userEmail: userEmail),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'My List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Navigation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
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
