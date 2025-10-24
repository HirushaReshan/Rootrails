import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserDrawer extends StatelessWidget {
const UserDrawer({super.key});


@override
Widget build(BuildContext context) {
final user = FirebaseAuth.instance.currentUser;
return Drawer(
child: SafeArea(
child: Column(children: [
UserAccountsDrawerHeader(accountName: Text(user?.displayName ?? 'Guest'), accountEmail: Text(user?.email ?? ''), currentAccountPicture: const CircleAvatar(child: Icon(Icons.person))),
ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () => Navigator.pop(context)),
ListTile(leading: const Icon(Icons.contact_mail), title: const Text('Contact us'), onTap: () {}),
ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () {}),
const Spacer(),
ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () async { await FirebaseAuth.instance.signOut(); Navigator.popUntil(context, (r) => r.isFirst); }),
]),
),
);
}
}