// lib/pages/user/user_home_page.dart
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/app_bar_with_notifications.dart';
import 'package:rootrails/models/park.dart';
import 'package:rootrails/services/firestore_service.dart';
import 'park_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBarWithNotifications(title: 'Parks', userId: userId),
      body: StreamBuilder<List<Park>>(
        stream: fs.streamParks(),
        builder: (c, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final parks = snap.data!;
          if (parks.isEmpty)
            return const Center(child: Text('No parks added yet'));
          return ListView.builder(
            itemCount: parks.length,
            itemBuilder: (context, i) {
              final p = parks[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(p.name),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ParkDetailPage(parkId: p.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
