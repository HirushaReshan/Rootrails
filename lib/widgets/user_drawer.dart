import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rootrails/services/auth_service.dart';
import 'package:rootrails/theme/app_themes.dart';
import 'package:rootrails/pages/common/role_selection_page.dart';
import 'package:rootrails/pages/general_user/my_list_page.dart';
import 'package:rootrails/pages/common/settings_page.dart';
import 'package:rootrails/pages/common/contact_us_page.dart';

// Note: Removed kPrimaryGreen and kLightGreenBackground as they are now dynamic

class UserDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;

  const UserDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  // Helper function to build consistent menu tiles
  Widget _buildDrawerTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    // Use theme colors for the icon and text
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ), // Dynamic Icon Color
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          color: theme.colorScheme.onSurface, // Dynamic Text Color
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeService = Provider.of<ThemeService>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine colors based on the current theme
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final drawerBackgroundColor = theme.scaffoldBackgroundColor;

    // Fallback for the custom bottom section background (using a lighter primary variant)
    final bottomBarColor = primaryColor.withOpacity(0.1);

    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.phone,
        'title': 'Contact Us',
        'page': const ContactUsPage(),
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'page': const SettingsPage(),
      },
      {
        'icon': Icons.list_alt,
        'title': 'My Bookings',
        'page': const MyListPage(),
      },
    ];

    return Drawer(
      backgroundColor: drawerBackgroundColor, // Dynamic Drawer Background
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
                  color: onSurfaceColor, // Dynamic Close Icon Color
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                // Placeholder for the optional Notification Bell
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Icon(
                    Icons.notifications_none,
                    size: 28,
                    color: primaryColor, // Dynamic Notification Icon Color
                  ),
                ),
              ],
            ),
          ),

          // Branded App Title (RooTrails logo spot)
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 5.0),
            child: Row(
              children: [
                Text(
                  'RooTrails',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    color: primaryColor, // Dynamic App Title Color
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
            color: onSurfaceColor.withOpacity(0.2), // Dynamic Divider Color
          ),

          // 2. MIDDLE SECTION (Scrollable Menu Items and Theme Switch)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // User Profile Info
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            primaryColor, // Dynamic Avatar Background
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: theme
                              .colorScheme
                              .onPrimary, // Icon color in Avatar
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              color: onSurfaceColor, // Dynamic Name Color
                            ),
                          ),
                          Text(
                            userEmail,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: onSurfaceColor.withOpacity(
                                0.6,
                              ), // Dynamic Email Color
                            ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => item['page'] as Widget,
                        ),
                      );
                    },
                  );
                }).toList(),

                Divider(
                  height: 30,
                  thickness: 0.5,
                  indent: 20,
                  endIndent: 20,
                  color: onSurfaceColor.withOpacity(
                    0.2,
                  ), // Dynamic Divider Color
                ),

                // Theme Switcher Logic
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
                          Icon(
                            Icons.brightness_6,
                            color: onSurfaceColor.withOpacity(0.6),
                          ), // Dynamic Icon Color
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Dark Mode',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                              ), // Dynamic Text Color
                            ),
                          ),
                          Switch(
                            value: themeService.currentTheme == AppTheme.dark,
                            onChanged: (value) => themeService.toggleTheme(),
                            activeColor:
                                primaryColor, // Dynamic Switch Active Color
                          ),
                        ],
                      ),
                      // Animal Theme Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.pets,
                            color: onSurfaceColor.withOpacity(0.6),
                          ), // Dynamic Icon Color
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Animal Theme',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                              ), // Dynamic Text Color
                            ),
                          ),
                          Switch(
                            value: themeService.currentTheme == AppTheme.animal,
                            onChanged: (value) => themeService.switchTheme(
                              value ? AppTheme.animal : AppTheme.light,
                            ),
                            activeColor:
                                primaryColor, // Dynamic Switch Active Color
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. BOTTOM SECTION (Logout and Custom Background)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.20,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: bottomBarColor,
              ), // Dynamic Bottom Bar Background
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder for the tree image/motif
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Icon(
                      Icons.nature,
                      size: 40,
                      color: primaryColor,
                    ), // Dynamic Icon Color
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Logout',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor, // Dynamic Text Color
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.logout,
                          color: onSurfaceColor,
                          size: 24,
                        ), // Dynamic Icon Color
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
