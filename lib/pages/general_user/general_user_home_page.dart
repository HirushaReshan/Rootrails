import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'my_list_page.dart';
import 'general_user_profile_page.dart'; // <<< NEW IMPORT
import '../common/navigation_page.dart';
// import other pages for NavigationBar items

// Placeholder Model for Park Data
class Park {
  final String id;
  final String name;
  final String imageUrl;
  final String openTime;
  final double rating;
  final bool isOpenNow;

  Park({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.openTime,
    required this.rating,
    required this.isOpenNow,
  });

  factory Park.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return Park(
      id: doc.id,
      name: data?['name'] ?? 'Unknown Park',
      imageUrl: data?['image_url'] ?? 'https://via.placeholder.com/150',
      openTime: data?['open_time'] ?? '9:00 AM - 5:00 PM',
      rating: (data?['rating'] is num) ? data!['rating'].toDouble() : 0.0,
      isOpenNow: data?['is_open'] ?? true, // Simplified status check
    );
  }
}

class GeneralUserHomePage extends StatefulWidget {
  const GeneralUserHomePage({super.key});

  @override
  State<GeneralUserHomePage> createState() => _GeneralUserHomePageState();
}

class _GeneralUserHomePageState extends State<GeneralUserHomePage> {
  int _selectedIndex = 0;
  String _currentUserName = 'Guest';

  final List<Widget> _pages = [
    const ParkListPage(), // Index 0: Home/Parks
    const MyListPage(), // Index 1: My List/Bookings
    const NavigationPage(), // Index 2: Navigation <<< UPDATED
    const GeneralUserProfilePage(), // Index 3: Profile <<< UPDATED
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Fetch the user's name from Firestore for the Drawer header
  Future<void> _fetchUserName() async {
    final user = AuthService().getCurrentUser();
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _currentUserName = doc.data()?['user_name'] ?? 'Traveler';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // List of pages for the bottom navigation bar
  final List<Widget> _pages = [
    const HomeContent(), // Index 0: Homepage Content
    const Center(child: Text('My List Page (Bookings)')), // Index 1: My List
    const Center(
      child: Text('Navigation Page (Logic TBA)'),
    ), // Index 2: Navigation
    const Center(child: Text('Profile Page')), // Index 3: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The App Bar is dynamically created to connect to the drawer
      appBar: AppBar(
        title: const Text('Safari Booker'),
      // The Drawer is the single source of truth for all drawer-related navigation and logic
      drawer: const GeneralDrawer(),

      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'My List', // <<< UPDATED LABEL
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Navigation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      ),
    );
  }
}

// --- HOME CONTENT WIDGET (The actual body of the Home Page) ---

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // --- Carousel Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              'Featured Safaris',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          const CarouselSection(),

          const SizedBox(height: 30),

          // --- Parks Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              'Explore Parks',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          const ParksSection(),

          const SizedBox(height: 30),

          // --- Other Businesses Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              'Other Safari Businesses',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          const OtherBusinessSection(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// --- CAROUSEL SLIDER WIDGET ---
class CarouselSection extends StatelessWidget {
  const CarouselSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('carousel_images')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No featured images available.'));
        }

        final List<String> imageUrls = snapshot.data!.docs
            .map(
              (doc) =>
                  (doc.data() as Map<String, dynamic>?)?['url'] as String? ??
                  'https://via.placeholder.com/300x150',
            )
            .toList();

        return CarouselSlider.builder(
          itemCount: imageUrls.length,
          itemBuilder: (context, index, realIndex) {
            return _buildCarouselItem(context, imageUrls[index]);
          },
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.85,
            autoPlayInterval: const Duration(seconds: 5),
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(BuildContext context, String imageUrl) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: const Text(
          'Explore Today',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// --- PARKS HORIZONTAL LIST WIDGET ---

class ParksSection extends StatelessWidget {
  const ParksSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch parks where 'type' is 'park'
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parks')
          .where('type', isEqualTo: 'park')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Text('No parks currently available.'),
          );
        }

        final List<Park> parks = snapshot.data!.docs
            .map((doc) => Park.fromFirestore(doc))
            .toList();

        return SizedBox(
          height: 250, // Height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: parks.length,
            itemBuilder: (context, index) {
              return _buildParkCard(context, parks[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildParkCard(BuildContext context, Park park) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to Park Detail Page
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tapped on ${park.name}')));
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(left: 15.0, right: 5.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Park Image
              Stack(
                children: [
                  Image.network(
                    park.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  ),
                  // Open/Closed Status Tag
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: park.isOpenNow
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        park.isOpenNow ? 'Open Now' : 'Closed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      park.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          park.openTime,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          park.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Check All Container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Check All',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- OTHER BUSINESSES HORIZONTAL LIST WIDGET (Reusing the card logic) ---

class OtherBusinessSection extends StatelessWidget {
  const OtherBusinessSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch businesses where 'type' is not 'park' (e.g., 'other_business')
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parks')
          .where('type', isEqualTo: 'other_business')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Text('No other businesses currently listed.'),
          );
        }

        final List<Park> businesses = snapshot.data!.docs
            .map((doc) => Park.fromFirestore(doc))
            .toList();

        return SizedBox(
          height: 250, // Height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              // Reusing Park Card for structural similarity, but it represents a business
              return _buildBusinessCard(context, businesses[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildBusinessCard(BuildContext context, Park business) {
    // Reusing the Park Card logic for structural consistency
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to Other Business Detail Page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped on Other Business: ${business.name}')),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(left: 15.0, right: 5.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Image
              Stack(
                children: [
                  Image.network(
                    business.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  ),
                  // Open/Closed Status Tag
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: business.isOpenNow
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        business.isOpenNow ? 'Open Now' : 'Closed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          business.openTime,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          business.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Check All Container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Check All',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
