import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/park.dart';
import 'package:rootrails/pages/general_user/park_detail_page.dart';

class ParkListPage extends StatelessWidget {
  const ParkListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Fetching all documents from the 'parks' collection
        stream: FirebaseFirestore.instance
            .collection('parks')
            .where('business_type', isEqualTo: 'park')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No parks or safari services available yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final List<Park> parks = snapshot.data!.docs
              .map((doc) => Park.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: parks.length,
            itemBuilder: (context, index) {
              return ParkCard(park: parks[index]);
            },
          );
        },
      ),
    );
  }
}

class ParkCard extends StatelessWidget {
  final Park park;

  const ParkCard({super.key, required this.park});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ParkDetailPage(park: park)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Park Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Image.network(
                park.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.photo, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Park Info
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    park.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        park.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Icon(
                        Icons.access_time,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Open: ${park.openTime}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap to view available drivers and book your next safari adventure.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
