import 'package:flutter/material.dart';
class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String title;

  const UserAppBar({super.key, required this.userName, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
