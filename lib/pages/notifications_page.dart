// lib/pages/common/notifications_page.dart
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/app_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatelessWidget {
  final String userId;
  const NotificationsPage({super.key, required this.userId});

  Future<void> _markRead(String id) async {
    await FirebaseFirestore.instance.collection('Notifications').doc(id).update({'read': true});
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<AppNotification>>(
        stream: fs.streamNotifications(userId),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty) return const Center(child: Text('No notifications'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final n = items[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(n.message),
                  subtitle: Text(n.type),
                  trailing: n.read ? null : TextButton(onPressed: () => _markRead(n.id), child: const Text('Mark read')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
