import 'package:flutter/material.dart';

typedef OnTabSelected = void Function(int index);

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final OnTabSelected onTap;
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My List'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Navigation'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
