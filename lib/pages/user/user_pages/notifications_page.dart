import 'package:flutter/material.dart';
import 'package:rootrails/models/app_notification.dart';
import 'package:rootrails/services/firestore_service.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = 'CURRENT_LOGGED_IN_USER_UID'; // replace with auth uid
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<AppNotification>>(
        stream: fs.streamNotifications(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final notifications = snapshot.data!;
          if (notifications.isEmpty)
            return const Center(child: Text('No notifications'));
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return ListTile(
                title: Text(n.message),
                subtitle: Text(n.type),
                trailing: n.read
                    ? null
                    : const Icon(Icons.fiber_new, color: Colors.red),
              );
            },
          );
        },
      ),
    );
  }
}
