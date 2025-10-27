import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/user_drawer.dart';
import '../../widgets/user_appbar.dart';
import 'park_page.dart';
import '../../widgets/bottom_nav.dart';
import '../user/my_bookings.dart';
import '../navigation/navigation_page.dart';
import 'profile_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentIndex = 0;
  final _fire = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeContent(fire: _fire),
      const MyBookingsPage(),
      const NavigationPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: const UserAppBar(title: 'RooTrails'),
      drawer: const UserDrawer(),
      body: pages[_currentIndex],
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final FirebaseFirestore fire;
  const HomeContent({super.key, required this.fire});

  bool _isOpen(String from, String to) {
    try {
      final now = TimeOfDay.now();
      final f = _parse(from);
      final t = _parse(to);
      final nMinutes = now.hour * 60 + now.minute;
      final fMinutes = f.hour * 60 + f.minute;
      final tMinutes = t.hour * 60 + t.minute;
      if (fMinutes <= tMinutes)
        return nMinutes >= fMinutes && nMinutes <= tMinutes;
      return nMinutes >= fMinutes || nMinutes <= tMinutes;
    } catch (e) {
      return false;
    }
  }

  TimeOfDay _parse(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Carousel from firestore: collection 'carousel_images' documents contain field 'imageUrl'
          StreamBuilder<QuerySnapshot>(
            stream: fire
                .collection('carousel_images')
                .orderBy('order', descending: false)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData)
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              final docs = snap.data!.docs;
              final urls = docs.map((d) => d['imageUrl'] as String).toList();
              if (urls.isEmpty)
                return const SizedBox(
                  height: 200,
                  child: Center(child: Text('No images available')),
                );
              return CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: urls
                    .map(
                      (u) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 8),
                            ],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.network(
                            u,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Parks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('See All')),
              ],
            ),
          ),
          // Horizontal parks list from collection 'parks'
          SizedBox(
            height: 220,
            child: StreamBuilder<QuerySnapshot>(
              stream: fire.collection('parks').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    final openFrom = d['openFrom'] ?? '06:00';
                    final openTo = d['openTo'] ?? '18:00';
                    final name = d['name'] ?? 'Park';
                    final image = d['imageUrl'] ?? '';
                    final rating = (d['rating'] ?? 4).toDouble();
                    final nowOpen = _isOpen(openFrom, openTo);
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ParkPage(parkId: d.id),
                        ),
                      ),
                      child: Container(
                        width: 260,
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                image,
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14),
                                      const SizedBox(width: 4),
                                      Text('$openFrom - $openTo'),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 14,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(rating.toString()),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: nowOpen
                                              ? Colors.green
                                              : Colors.grey,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          nowOpen ? 'Open' : 'Closed',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Other businesses sample
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: const [
                Text(
                  'Other Businesses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: StreamBuilder<QuerySnapshot>(
              stream: fire.collection('businesses').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    return Container(
                      width: 260,
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        children: [
                          if ((d['imageUrl'] ?? '') != '')
                            Image.network(
                              d['imageUrl'],
                              width: 110,
                              height: 140,
                              fit: BoxFit.cover,
                            )
                          else
                            Container(width: 110, color: Colors.grey),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d['business_name'] ?? 'Business',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    d['description'] ?? '',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
