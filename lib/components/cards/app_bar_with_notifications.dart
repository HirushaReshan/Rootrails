// lib/components/app_bar_with_notifications.dart
import 'package:flutter/material.dart';
import 'package:rootrails/models/app_notification.dart';
import 'package:rootrails/pages/notifications_page.dart';
import 'package:rootrails/services/firestore_service.dart';

class AppBarWithNotifications extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String userId;
  const AppBarWithNotifications({
    super.key,
    required this.title,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        StreamBuilder<List<AppNotification>>(
          stream: FirestoreService().streamNotifications(userId),
          builder: (context, snap) {
            final unread = snap.data?.where((n) => !n.read).length ?? 0;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationsPage(userId: userId),
                    ),
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
