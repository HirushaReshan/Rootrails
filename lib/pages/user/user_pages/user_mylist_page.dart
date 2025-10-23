// lib/pages/user/user_mylist_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserMyListPage extends StatelessWidget {
  const UserMyListPage({super.key});

  Future<List<QueryDocumentSnapshot>> _fetch() async {
    final user = FirebaseAuth.instance.currentUser!;
    final snap = await FirebaseFirestore.instance.collection('Reservations').where('userId', isEqualTo: user.uid).orderBy('requestedAt', descending: true).get();
    return snap.docs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(future: _fetch(), builder: (c, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      final docs = snap.data ?? [];
      if (docs.isEmpty) return const Center(child: Text('No reservations'));
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final d = docs[i].data() as Map<String, dynamic>;
          final pick = d['pickUpAt'] != null ? (d['pickUpAt'] as Timestamp).toDate().toLocal().toString() : 'No time';
          return ListTile(title: Text(d['driverName'] ?? d['parkName'] ?? 'Reservation'), subtitle: Text('At: $pick\nStatus: ${d['status'] ?? '-'}'));
        },
      );
    });
  }
}
