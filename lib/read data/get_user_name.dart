// lib/read_data/get_user_name.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/pages/park_detail_page.dart';

class GetUserName extends StatelessWidget {
  final String documentId;
  const GetUserName({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    final parks = FirebaseFirestore.instance.collection('Parks');
    return FutureBuilder<DocumentSnapshot>(
      future: parks.doc(documentId).get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snap.hasData || snap.hasError) return const Text('Error');
        final data = snap.data!.data() as Map<String, dynamic>;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((data['imageUrl'] ?? '').toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data['imageUrl'],
                  width: double.infinity,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              data['name'] ?? 'No name',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              data['description'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ParkDetailPage(parkId: documentId),
                  ),
                ),
                child: const Text('View / Reserve'),
              ),
            ),
          ],
        );
      },
    );
  }
}
