// lib/pages/business/business_orders_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusinessOrdersPage extends StatelessWidget {
  const BusinessOrdersPage({super.key});

  Future<List<QueryDocumentSnapshot>> _completed() async {
    final snap = await FirebaseFirestore.instance
        .collection('Reservations')
        .where('status', isEqualTo: 'completed')
        .get();
    return snap.docs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _completed(),
      builder: (c, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snap.data!;
        num total = 0;
        for (var d in docs) {
          final m = (d.data() as Map<String, dynamic>)['amount'];
          if (m is num) total += m;
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Total earnings: LKR $total',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (c, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final pick = d['pickUpAt'] != null
                      ? (d['pickUpAt'] as Timestamp).toDate().toString()
                      : 'N/A';
                  return ListTile(
                    title: Text(d['driverName'] ?? ''),
                    subtitle: Text('At $pick — LKR ${d['amount'] ?? 0}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
