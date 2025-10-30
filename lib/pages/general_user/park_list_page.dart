import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/park.dart';
import 'package:rootrails/pages/general_user/park_detail_page.dart';
import 'package:rootrails/utils/image_carousel.dart';

// --- Global Constants ---
const Color kPrimaryGreen = Color(0xFF4C7D4D); // Define color

class ParkListPage extends StatelessWidget {
  const ParkListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen height to set carousel height dynamically
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. CAROUSEL STREAM BUILDER (TOP) ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(
                    'carousel_images',
                  ) // Fetch from dedicated collection
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Display a simple loading placeholder for the carousel area
                  return Container(
                    height:
                        screenHeight * 0.25 + 20, // Height + vertical margins
                    child: const Center(
                      child: CircularProgressIndicator(color: kPrimaryGreen),
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox.shrink(); // Hide if error or no data
                }

                // Extract all imageUrls from the documents
                final imageUrls = snapshot.data!.docs
                    .map((doc) => doc['imageUrl'] as String)
                    .where((url) => url.isNotEmpty)
                    .toList();

                // Use the custom ImageCarousel component
                return ImageCarousel(
                  imageUrls: imageUrls,
                  height: screenHeight * 0.25,
                  autoPlay: true,
                );
              },
            ),

            // --- PARK LIST HEADER ---
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 20.0,
                bottom: 5.0,
              ),
              child: Text(
                'Explore National Parks',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // --- 2. PARK LIST STREAM BUILDER ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('parks')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: kPrimaryGreen),
                    ),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        'No national parks are available at this time.',
                      ),
                    ),
                  );
                }

                final parks = snapshot.data!.docs
                    .map((doc) => Park.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  shrinkWrap:
                      true, // Crucial for a ListView inside SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  itemCount: parks.length,
                  itemBuilder: (context, index) {
                    return ParkCard(park: parks[index]);
                  },
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// --- ParkCard Widget (Remains the same, but using kPrimaryGreen for consistency) ---
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
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Park Image
            Container(
              height: 200,
              width: double.infinity,
              child: Image.network(
                park.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.park, size: 50, color: kPrimaryGreen),
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
                      Icon(Icons.access_time, color: kPrimaryGreen, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Open: ${park.openTime}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap to view available drivers.',
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
