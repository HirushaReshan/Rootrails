import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return Scaffold(body: const Center(child: Text('Not signed in')));
    final stream = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No bookings yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final status = d['status'] ?? 'pending';
              final date = d['date'] is Timestamp
                  ? (d['date'] as Timestamp).toDate()
                  : (d['date'] ?? null);
              final dateStr = date != null
                  ? DateFormat.yMMMd().format(date)
                  : 'N/A';
              final time = d['time'] ?? '';
              final driverId = d['driverId'] ?? '';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text('Driver: ${d['driverName'] ?? driverId}'),
                  subtitle: Text('$dateStr • $time\nStatus: $status'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'cancel') {
                        await FirebaseFirestore.instance
                            .collection('bookings')
                            .doc(d.id)
                            .update({'status': 'canceled'});
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Text('Cancel'),
                      ),
                    ],
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
