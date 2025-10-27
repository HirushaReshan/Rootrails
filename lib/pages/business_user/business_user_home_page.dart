import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/business.dart';
import 'package:rootrails/widgets/business_drawer.dart';
import 'business_orders_page.dart';
import '../common/navigation_page.dart';
// import pages for Orders, Navigation, Profile

class BusinessUserHomePage extends StatefulWidget {
  const BusinessUserHomePage({super.key});

  @override
  State<BusinessUserHomePage> createState() => _BusinessUserHomePageState();
}

class _BusinessUserHomePageState extends State<BusinessUserHomePage> {
  int _selectedIndex = 0;
  Business? _business;

  @override
  void initState() {
    super.initState();
    _fetchBusinessDetails();
  }

  // Fetch the Business details from Firestore
  Future<void> _fetchBusinessDetails() async {
    final user = AuthService().getCurrentUser();
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _business = Business.fromFirestore(doc);
        });
      }
    }
  }

  // Toggle the business open/closed status
  Future<void> _toggleBusinessStatus(bool newStatus) async {
    if (_business == null) return;
    
    // Confirmation dialog if closing
    if (_business!.isOpen && !newStatus) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Close'),
          content: const Text('Are you sure you want to close your business? This will prevent new bookings.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
          ],
        ),
      );
      if (confirm != true) return;
    }

    try {
      // Update local state first for quick feedback
      setState(() {
        _business = Business(
          ..._business!.toFirestore(), // Spread existing data
          uid: _business!.uid,
          email: _business!.email,
          isOpen: newStatus,
        );
      });

      // Update Firestore 'users' collection (profile)
      await FirebaseFirestore.instance.collection('users').doc(_business!.uid).update({
        'is_open': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      // Update Firestore 'parks' collection (public listing)
      await FirebaseFirestore.instance.collection('parks').doc(_business!.uid).update({
        'is_open': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_business!.isOpen ? 'Business is now OPEN!' : 'Business is now CLOSED.')),
        );
      }
    } catch (e) {
      // Revert local state if update fails
      _fetchBusinessDetails(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  final List<Widget> _pages = [
    const BusinessHomeContent(business: null, onToggleStatus: null), // Placeholder, content handled below
    const BusinessOrdersPage(), // Index 1: Orders <<< UPDATED
    const Center(child: Text('Navigation Page (Logic TBA)')), // Index 2: Navigation
    const Center(child: Text('Profile Page (Business)')), // Index 3: Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> businessPages = [
        BusinessHomeContent(
            business: _business!,
            onToggleStatus: _toggleBusinessStatus,
          ),
        const BusinessOrdersPage(),
        const NavigationPage(), // <<< UPDATED
        const BusinessProfilePage(), // <<< UPDATED
    ];
    
    if (_business == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final List<Widget> businessPages = [
        BusinessHomeContent(
            business: _business!,
            onToggleStatus: _toggleBusinessStatus,
          ),
        const BusinessOrdersPage(),
        const Center(child: Text('Navigation Page (Logic TBA)')),
        const Center(child: Text('Profile Page (Business)')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_business!.businessName),
        actions: [
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              // TODO: Navigate to Notification Page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Showing new booking notifications.')),
              );
            },
          ),
        ],
      ),
      drawer: BusinessDrawer(
        businessName: _business!.businessName,
        driverImageUrl: _business!.driverImageUrl,
      ),
      
      body: businessPages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Navigation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_outlined),
            activeIcon: Icon(Icons.person_pin),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --- HOME CONTENT WIDGET (The actual dashboard) ---

class BusinessHomeContent extends StatelessWidget {
  final Business business;
  final Function(bool) onToggleStatus;

  const BusinessHomeContent({
    super.key,
    required this.business,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Status Toggle Card
          Card(
            color: business.isOpen ? Colors.green.shade100 : Colors.red.shade100,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    business.isOpen ? 'Business is OPEN' : 'Business is CLOSED',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: business.isOpen ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                  Switch(
                    value: business.isOpen,
                    onChanged: onToggleStatus,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Business Details Card
          Text(
            'Your Business Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(business.driverImageUrl),
                      onBackgroundImageError: (exception, stackTrace) => const Icon(Icons.person, size: 40),
                    ),
                  ),
                  const Divider(height: 30),
                  _buildDetailRow(context, 'Name', business.businessName, Icons.badge),
                  _buildDetailRow(context, 'Type', business.businessType.toUpperCase(), Icons.category),
                  _buildDetailRow(context, 'Price', '\$${business.pricePerSafari.toStringAsFixed(2)}', Icons.monetization_on),
                  _buildDetailRow(context, 'Duration', '${business.safariDurationHours} hours', Icons.timer),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Details'),
                      onPressed: () {
                        // TODO: Navigate to Business Profile Edit Page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Navigating to profile edit page.')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Stats (Placeholder for future implementation)
          Text(
            'Performance Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatCard(context, 'Pending Orders', '3', Icons.pending_actions, Colors.orange),
              _buildStatCard(context, 'Rating', '${business.rating.toStringAsFixed(1)} ★', Icons.star_rate, Colors.amber),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color.darken(10)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple color utility for the stat cards
extension ColorExtension on Color {
  Color darken([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    final f = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * f).round(),
      (green * f).round(),
      (blue * f).round(),
    );
  }
}