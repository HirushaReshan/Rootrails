// lib/pages/park_detail_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_card.dart';
import 'package:rootrails/pages/business_detail_page.dart';

class ParkDetailPage extends StatelessWidget {
  final String parkId;
  const ParkDetailPage({super.key, required this.parkId});

  @override
  Widget build(BuildContext context) {
    final parkRef = FirebaseFirestore.instance.collection('Parks').doc(parkId);

    return Scaffold(
      appBar: AppBar(title: const Text('Park Details')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: parkRef.snapshots(),
        builder: (context, parkSnap) {
          if (parkSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!parkSnap.hasData || !parkSnap.data!.exists) {
            return const Center(child: Text('Park not found'));
          }

          final parkData = parkSnap.data!.data() as Map<String, dynamic>? ?? {};

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Park image/header
              if ((parkData['imageUrl'] ?? '').toString().isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Image.network(
                    parkData['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parkData['name'] ?? 'Unnamed Park',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(parkData['location'] ?? ''),
                    const SizedBox(height: 8),
                    Text(parkData['description'] ?? ''),
                  ],
                ),
              ),

              const Divider(),

              // Businesses header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: const Text('Businesses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),

              // Businesses horizontal list (business is the "driver")
              SizedBox(
                height: 170,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Business_Users')
                      .where('parkIds', arrayContains: parkId)
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No businesses registered to this park yet'));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final b = docs[i].data() as Map<String, dynamic>? ?? {};
                        final businessId = docs[i].id;
                        return SizedBox(
                          width: 260,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: MyCard(
                              title: b['businessName'] ?? '',
                              subtitle: b['businessDescription'] ?? '',
                              imageUrl: '/lib/images/1.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BusinessDetailPage(
                                      parkId: parkId,
                                      parkData: parkData,
                                      businessId: businessId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // no drivers section — business == driver so not needed
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
