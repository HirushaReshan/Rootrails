// lib/pages/user/park_detail_page.dart
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/app_bar_with_notifications.dart';
import 'package:rootrails/models/business_user.dart';
import 'package:rootrails/services/firestore_service.dart';
import 'business_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParkDetailPage extends StatelessWidget {
  final String parkId;
  const ParkDetailPage({super.key, required this.parkId});
  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBarWithNotifications(title: 'Park', userId: userId),
      body: StreamBuilder<List<BusinessUser>>(
        stream: fs.streamBusinesses(),
        builder: (c, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final list = snap.data!
              .where((b) => b.parkIds.contains(parkId))
              .toList();
          if (list.isEmpty)
            return const Center(
              child: Text('No drivers/businesses for this park'),
            );
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final b = list[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: b.imageUrl.isNotEmpty
                      ? Image.network(
                          b.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : null,
                  title: Text(b.businessName),
                  subtitle: Text(b.description),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusinessDetailPage(businessId: b.uid),
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
