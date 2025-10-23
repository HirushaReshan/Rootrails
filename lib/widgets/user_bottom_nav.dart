import 'package:flutter/material.dart';
import 'package:rootrails/pages/user/user_pages/user_home_page.dart';
import 'package:rootrails/pages/user/user_pages/user_bookings_page.dart';
import 'package:rootrails/pages/notifications_page.dart';

class UserBottomNav extends StatefulWidget {
  final String userId;
  const UserBottomNav({super.key, required this.userId});

  @override
  State<UserBottomNav> createState() => _UserBottomNavState();
}

class _UserBottomNavState extends State<UserBottomNav> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      UserHomePage(userId: widget.userId),
      UserBookingsPage(userId: widget.userId),
      NotificationsPage(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
