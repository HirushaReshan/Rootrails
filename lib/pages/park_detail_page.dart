import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_card.dart';

class ParkDetailPage extends StatelessWidget {
  final String parkId;
  const ParkDetailPage({super.key, required this.parkId});

  @override
  Widget build(BuildContext context) {
    final parkRef = FirebaseFirestore.instance.collection('Parks').doc(parkId);

    return Scaffold(
      appBar: AppBar(title: const Text('Park Details')),
      body: FutureBuilder(
        future: parkRef.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final parkData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              Text(parkData['name'] ?? 'Unnamed Park', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(parkData['location'] ?? ''),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Business_Users')
                      .where('parkId', isEqualTo: parkId)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                    final businesses = snap.data!.docs;
                    return ListView.builder(
                      itemCount: businesses.length,
                      itemBuilder: (context, index) {
                        final b = businesses[index];
                        return MyCard(
                          title: b['businessName'] ?? '',
                          subtitle: b['businessDescription'] ?? '',
                          imageUrl: b['imageUrl'],
                          onTap: () {
                            Navigator.pushNamed(context, '/business_detail', arguments: b.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
