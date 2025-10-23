import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/carousel/carousel.dart';
import 'package:rootrails/components/drawer/business_drawer.dart';
import 'package:rootrails/read%20data/get_user_name.dart';

class BusinessHomePage extends StatefulWidget {
  BusinessHomePage({super.key});

  @override
  State<BusinessHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<BusinessHomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  // get Document IDs and return them
  Future<List<String>> getDocId() async {
    final snapshot = await FirebaseFirestore.instance.collection('Parks').get();
    return snapshot.docs.map((d) => d.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.25;
    final parksListHeight = screenHeight * 0.5; // adjust as needed

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade400,
        title: Text(
          'Logged in as : ${user.email!}',
          style: TextStyle(color: Colors.grey[300], fontSize: 16),
        ),
      ),
      drawer: BusinessDrawer(),
      // Entire page scrolls vertically
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Business Page',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Image carousel (bounded height)
              ImageCarousel(
                imagePaths: [
                  'lib/images/1.jpg',
                  'lib/images/2.jpg',
                  'lib/images/3.jpg',
                ],
                height: carouselHeight,
              ),
              const SizedBox(height: 18),

              // Section title
              const Text(
                'Parks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // Horizontal parks list (bounded height so it can scroll horizontally)
              SizedBox(
                height: parksListHeight,
                child: FutureBuilder<List<String>>(
                  future: getDocId(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final ids = snapshot.data ?? [];

                    if (ids.isEmpty) {
                      return const Center(child: Text('No parks found.'));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: ids.length,
                      itemBuilder: (context, index) {
                        final id = ids[index];
                        return Container(
                          width: 300, // card width — tweak to taste
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Example: park name (from GetUserName) and an action button
                                  Expanded(
                                    child: Center(
                                      child: GetUserName(documentId: id),
                                    ),
                                  ),
                                  
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Example: more vertically-scrolling content after the horizontal list
              const SizedBox(height: 20),
              const Text('Other content below the parks...'),
              const SizedBox(height: 600), // remove or replace with real content
            ],
          ),
        ),
      ),
    );
  }
}
