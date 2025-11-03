import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rootrails/services/auth_service.dart';
import 'package:rootrails/theme/app_themes.dart';
import 'package:rootrails/pages/common/role_selection_page.dart';
import 'package:rootrails/pages/general_user/my_list_page.dart';
import 'package:rootrails/pages/common/settings_page.dart';
import 'package:rootrails/pages/common/contact_us_page.dart';

const Color kPrimaryGreen = Color(0xFF4C7D4D);
const Color kLightGreenBackground = Color(0xFFE6F4E6);

class UserDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;

  const UserDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  Widget _buildDrawerTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryGreen),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.phone,
        'title': 'Contact Us',
        'page': const ContactUsPage(),
      },
      // {'icon': Icons.pets, 'title': 'About Us', 'page': const Text('About Us Page Placeholder')}, // Removed placeholder
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'page': const SettingsPage(),
      },
      // {'icon': Icons.history, 'title': 'Ride History', 'page': const Text('Ride History Page Placeholder')}, // Removed placeholder
      // {'icon': Icons.help_outline, 'title': 'Help & Support', 'page': const Text('Help & Support Page Placeholder')}, // Removed placeholder
      // {'icon': Icons.notifications_none, 'title': 'Notifications', 'page': const Text('Notifications Page Placeholder')}, // Removed placeholder
      // {'icon': Icons.person_outline, 'title': 'My Profile', 'page': const Text('My Profile Page Placeholder')}, // Removed placeholder
      {
        'icon': Icons.list_alt,
        'title': 'My Bookings',
        'page': const MyListPage(),
      }, // Kept original functional item
    ];

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          // 1. TOP SECTION (Close Button and Logo)
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 5,
              left: 10,
            ),
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 30),
                  color: Colors.black,
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                // Placeholder for the optional Notification Bell
                const Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: Icon(
                    Icons.notifications_none,
                    size: 28,
                    color: kPrimaryGreen,
                  ),
                ),
              ],
            ),
          ),

          // Branded App Title (RooTrails logo spot)
          const Padding(
            padding: EdgeInsets.only(left: 20.0, bottom: 5.0),
            child: Row(
              children: [
                Text(
                  'RooTrails',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGreen,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20),

          // 2. MIDDLE SECTION (Scrollable Menu Items and Theme Switch)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // User Profile Info (Replacing UserAccountsDrawerHeader area)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: kPrimaryGreen,
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            userEmail,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // List of core functional items
                ...menuItems.map((item) {
                  return _buildDrawerTile(
                    context,
                    item['icon'] as IconData,
                    item['title'] as String,
                    () {
                      Navigator.pop(context);
                      // Custom navigation based on the list item's page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => item['page'] as Widget,
                        ),
                      );
                    },
                  );
                }).toList(),

                const Divider(
                  height: 30,
                  thickness: 0.5,
                  indent: 20,
                  endIndent: 20,
                ),

                // Theme Switcher Logic (Retained)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    children: [
                      // Dark Mode Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.brightness_6, color: Colors.grey),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Dark Mode',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Switch(
                            value: themeService.currentTheme == AppTheme.dark,
                            onChanged: (value) => themeService.toggleTheme(),
                            activeColor: kPrimaryGreen,
                          ),
                        ],
                      ),
                      // Animal Theme Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.pets, color: Colors.grey),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Animal Theme',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Switch(
                            value: themeService.currentTheme == AppTheme.animal,
                            onChanged: (value) => themeService.switchTheme(
                              value ? AppTheme.animal : AppTheme.light,
                            ),
                            activeColor: kPrimaryGreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. BOTTOM SECTION
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.20, // Height of the custom bottom bar
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(color: kLightGreenBackground),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder for the tree image/motif
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Icon(Icons.nature, size: 40, color: Colors.green),
                  ),

                  // Logout Button
                  GestureDetector(
                    onTap: () async {
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const RoleSelectionPage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.logout, color: Colors.black87, size: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
