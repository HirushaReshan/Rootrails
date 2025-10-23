// lib/pages/navigation/business_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:rootrails/pages/business/business_pages/business_earnings_page.dart';
import 'package:rootrails/pages/business/business_pages/business_home_page.dart';
import 'package:rootrails/pages/business/business_pages/business_profile_page.dart';
import 'package:rootrails/pages/notifications_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessBottomNav extends StatefulWidget {
  final String businessId;
  const BusinessBottomNav({super.key, this.businessId = ''});

  @override
  State<BusinessBottomNav> createState() => _BusinessBottomNavState();
}

class _BusinessBottomNavState extends State<BusinessBottomNav> {
  int _index = 0;
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final businessId = widget.businessId.isNotEmpty
        ? widget.businessId
        : (_user?.uid ?? '');
    final pages = [
      BusinessHomePage(businessId: businessId),
      BusinessEarningsPage(businessId: businessId),
      NotificationsPage(userId: businessId),
      BusinessProfilePage(businessId: businessId),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
