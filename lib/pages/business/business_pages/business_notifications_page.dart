import 'package:flutter/material.dart';
import 'package:rootrails/models/app_notification.dart';
import 'package:rootrails/services/firestore_service.dart';

class BusinessNotificationsPage extends StatelessWidget {
  final String businessId;
  const BusinessNotificationsPage({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<AppNotification>>(
        stream: fs.streamNotifications(businessId),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final notifications = snapshot.data!;
          if (notifications.isEmpty)
            return const Center(child: Text('No notifications.'));
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(n.message),
                  subtitle: Text(n.type),
                  trailing: n.read
                      ? const Icon(Icons.done, color: Colors.green)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
