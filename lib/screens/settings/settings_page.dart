import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: appState.themeMode == ThemeMode.dark,
            onChanged: (v) =>
                appState.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
          ),
          ListTile(
            title: const Text('Animal theme'),
            subtitle: const Text('Apply nature/animal color accents'),
            trailing: ElevatedButton(
              onPressed: () => appState.setThemeMode(ThemeMode.system),
              child: const Text('Apply'),
            ),
          ),
          ListTile(
            title: const Text('Contact us'),
            subtitle: const Text('support@rootrails.app'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseService.auth.signOut();
              Navigator.popUntil(context, (r) => r.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
