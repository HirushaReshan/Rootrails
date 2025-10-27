import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'business_profile.dart';

class BusinessProfileTab extends StatelessWidget {
  const BusinessProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Not signed in'));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('businesses')
          .doc(uid)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final d = snap.data!;
        final name = d['business_name'] ?? '';
        final image = d['imageUrl'] ?? '';
        final price = d['price'] ?? 0;
        final parkId = d['parkId'] ?? '';
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: image != '' ? NetworkImage(image) : null,
                    child: image == '' ? const Icon(Icons.store) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('From \$${price.toString()}'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BusinessProfile(),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Assigned park: ${parkId.isEmpty ? 'None' : parkId}'),
              const SizedBox(height: 12),
              const Text(
                'Statistics',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('businessId', isEqualTo: uid)
                    .snapshots(),
                builder: (context, snap2) {
                  if (!snap2.hasData) return const SizedBox();
                  final docs = snap2.data!.docs;
                  final total = docs.length;
                  final confirmed = docs
                      .where((b) => (b['status'] ?? '') == 'confirmed')
                      .length;
                  final earnings = docs.fold<double>(
                    0,
                    (prev, b) =>
                        prev +
                        (double.tryParse((b['amount'] ?? '0').toString()) ?? 0),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total bookings: $total'),
                      Text('Confirmed: $confirmed'),
                      Text('Earnings: \$${earnings.toStringAsFixed(2)}'),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
