import 'package:flutter/material.dart';


class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
final String title;
const UserAppBar({super.key, required this.title});


@override
Widget build(BuildContext context) {
return AppBar(title: Text(title), actions: [IconButton(onPressed: () { /* TODO notifications */ }, icon: const Icon(Icons.notifications))]);
}


@override
Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}