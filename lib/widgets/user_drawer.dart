import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rootrails/services/auth_service.dart';
import 'package:rootrails/theme/app_themes.dart';
import 'package:rootrails/pages/common/role_selection_page.dart';
import 'package:rootrails/pages/general_user/my_list_page.dart';
import 'package:rootrails/pages/common/settings_page.dart';
import 'package:rootrails/pages/common/contact_us_page.dart';

class UserDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;

  const UserDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('My Bookings'),
            onTap: () {
              Navigator.pop(context);
              // Direct navigation for simplicity in the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactUsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          const Divider(),
          // Theme Switcher Logic
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.brightness_6),
                        const SizedBox(width: 30),
                        Text(
                          'Dark Mode',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Switch(
                      value: themeService.currentTheme == AppTheme.dark,
                      onChanged: (value) => themeService.toggleTheme(),
                      activeColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pets),
                        const SizedBox(width: 30),
                        Text(
                          'Animal Theme',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Switch(
                      value: themeService.currentTheme == AppTheme.animal,
                      onChanged: (value) => themeService.switchTheme(
                        value ? AppTheme.animal : AppTheme.light,
                      ),
                      activeColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
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
          ),
        ],
      ),
    );
  }
}
