// lib/pages/user/user_past_travels_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserPastTravelsPage extends StatelessWidget {
  const UserPastTravelsPage({super.key});

  Future<List<QueryDocumentSnapshot>> _fetchPast() async {
    final user = FirebaseAuth.instance.currentUser!;
    final snap = await FirebaseFirestore.instance
        .collection('Reservations')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'completed')
        .orderBy('pickUpAt', descending: true)
        .get();
    return snap.docs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _fetchPast(),
      builder: (c, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        final docs = snap.data ?? [];
        if (docs.isEmpty) return const Center(child: Text('No past travels'));
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final pick = d['pickUpAt'] != null
                ? (d['pickUpAt'] as Timestamp).toDate().toLocal().toString()
                : 'N/A';
            return ListTile(
              title: Text('${d['driverName'] ?? ''} — ${d['parkName'] ?? ''}'),
              subtitle: Text('At: $pick\nAmount: LKR ${d['amount'] ?? 0}'),
              onTap: () {
                // open details & rating UI if not rated
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PastTravelDetailPage(
                      reservationId: docs[i].id,
                      reservationData: d,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class PastTravelDetailPage extends StatefulWidget {
  final String reservationId;
  final Map<String, dynamic> reservationData;
  const PastTravelDetailPage({
    super.key,
    required this.reservationId,
    required this.reservationData,
  });
  @override
  State<PastTravelDetailPage> createState() => _PastTravelDetailPageState();
}

class _PastTravelDetailPageState extends State<PastTravelDetailPage> {
  int _rating = 5;
  final _commentController = TextEditingController();

  Future<void> submitReview() async {
    final driverId = widget.reservationData['driverId'];
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // add review
    final review = {
      'userId': user.uid,
      'rating': _rating,
      'comment': _commentController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance
        .collection('Parks')
        .doc(widget.reservationData['parkId'])
        .collection('Drivers')
        .doc(driverId)
        .collection('Reviews')
        .add(review);

    // update driver average: simple approach read all reviews and compute avg (not optimal but ok)
    final reviewsSnap = await FirebaseFirestore.instance
        .collection('Parks')
        .doc(widget.reservationData['parkId'])
        .collection('Drivers')
        .doc(driverId)
        .collection('Reviews')
        .get();
    double sum = 0;
    for (var r in reviewsSnap.docs)
      sum += (r.data() as Map<String, dynamic>)['rating'] ?? 0;
    final avg = reviewsSnap.docs.isNotEmpty
        ? sum / reviewsSnap.docs.length
        : 0.0;
    await FirebaseFirestore.instance
        .collection('Parks')
        .doc(widget.reservationData['parkId'])
        .collection('Drivers')
        .doc(driverId)
        .update({'averageRating': avg, 'ratingCount': reviewsSnap.docs.length});

    // maybe mark reservation as reviewed (optional)
    await FirebaseFirestore.instance
        .collection('Reservations')
        .doc(widget.reservationId)
        .update({'reviewed': true});

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thanks for rating')));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.reservationData;
    return Scaffold(
      appBar: AppBar(title: const Text('Past Travel')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              '${d['driverName']} — ${d['parkName']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Rate the driver'),
            Slider(
              value: _rating.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_rating',
              onChanged: (v) => setState(() => _rating = v.toInt()),
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: submitReview,
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
