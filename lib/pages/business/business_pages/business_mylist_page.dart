// lib/pages/business/business_mylist_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusinessMyListPage extends StatefulWidget {
  const BusinessMyListPage({super.key});
  @override
  State<BusinessMyListPage> createState() => _BusinessMyListPageState();
}

class _BusinessMyListPageState extends State<BusinessMyListPage> {
  Future<List<QueryDocumentSnapshot>> _fetchPending() async {
    final snap = await FirebaseFirestore.instance
        .collection('Reservations')
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .get();
    return snap.docs;
  }

  Future<void> _confirm(String id, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('Reservations').doc(id).update({
      'status': 'confirmed',
    });
    // notify user
    await FirebaseFirestore.instance.collection('Notifications').add({
      'userId': data['userId'],
      'title': 'Reservation confirmed',
      'body': 'Your reservation for ${data['driverName']} is confirmed.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    setState(() {});
  }

  Future<void> _cancel(String id, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('Reservations').doc(id).update({
      'status': 'cancelled',
    });
    // refund logic: if paymentId exists set Payments.status to 'refunded' or 'partial_refund'
    if ((data['paymentId'] ?? '').toString().isNotEmpty) {
      final payRef = FirebaseFirestore.instance
          .collection('Payments')
          .doc(data['paymentId']);
      await payRef.update({'status': 'refunded'});
    }
    // notify user
    await FirebaseFirestore.instance.collection('Notifications').add({
      'userId': data['userId'],
      'title': 'Reservation cancelled',
      'body':
          'Your reservation for ${data['driverName']} was cancelled. Refund processed.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _fetchPending(),
      builder: (c, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snap.data!;
        if (docs.isEmpty)
          return const Center(child: Text('No pending requests'));
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final d = doc.data() as Map<String, dynamic>;
            final pick = d['pickUpAt'] != null
                ? (d['pickUpAt'] as Timestamp).toDate().toString()
                : 'N/A';
            return Card(
              child: ListTile(
                title: Text('${d['driverName']} — ${d['parkName']}'),
                subtitle: Text('User: ${d['userEmail']}\nAt: $pick'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _confirm(doc.id, d),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _cancel(doc.id, d),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
