import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessOrders extends StatelessWidget {
  const BusinessOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return Scaffold(body: const Center(child: Text('Not signed in')));
    final stream = FirebaseFirestore.instance
        .collection('bookings')
        .where('businessId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No orders yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final status = d['status'] ?? 'pending';
              final userId = d['userId'] ?? '';
              final date = d['date'] is Timestamp
                  ? (d['date'] as Timestamp).toDate()
                  : null;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text('Booking from ${d['userName'] ?? userId}'),
                  subtitle: Text(
                    'Status: $status\nDate: ${date != null ? date.toLocal().toString().split(' ')[0] : 'N/A'}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == 'pending')
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async => await FirebaseFirestore
                              .instance
                              .collection('bookings')
                              .doc(d.id)
                              .update({'status': 'confirmed'}),
                        ),
                      if (status != 'canceled')
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async => await FirebaseFirestore
                              .instance
                              .collection('bookings')
                              .doc(d.id)
                              .update({'status': 'canceled'}),
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
