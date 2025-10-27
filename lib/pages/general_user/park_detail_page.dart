import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/driver.dart';
import 'package:rootrails/pages/general_user/general_user_home_page.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'driver_detail_page.dart';

class ParkDetailPage extends StatelessWidget {
  final Park park;

  const ParkDetailPage({super.key, required this.park});

  // Function to open Google Maps
  void _openMap(BuildContext context, String location) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$location';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open map.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(park.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParkInfoSection(context),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Text(
                'Available Drivers',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            _buildDriverList(context),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildParkInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            park.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Open: ${park.openTime}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber.shade700),
              const SizedBox(width: 4),
              Text(
                'Rating: ${park.rating.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openMap(
                  context,
                  park.name,
                ), // Using park name as location query
                icon: const Icon(Icons.location_on),
                label: const Text('View on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'About the Park: A beautiful destination for wildlife viewing and conservation. Check the open times before booking!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverList(BuildContext context) {
    // Fetch drivers associated with this park (Park ID is implicitly the park name/identifier)
    // We are querying the 'parks' collection (which also holds business listings) for matching types/locations
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parks')
          .where('business_type', isEqualTo: 'park')
          .where(
            'park_id',
            isEqualTo: park.id,
          ) // Assuming park.id is the unique park identifier
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No drivers registered for this park yet.'),
            ),
          );
        }

        final List<Driver> drivers = snapshot.data!.docs
            .map((doc) => Driver.fromFirestore(doc))
            .toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            return _buildDriverCard(context, drivers[index]);
          },
        );
      },
    );
  }

  Widget _buildDriverCard(BuildContext context, Driver driver) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DriverDetailPage(driver: driver, parkName: park.name),
            ),
          );
        },
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(driver.driverImageUrl),
          onBackgroundImageError: (e, s) => const Icon(Icons.person, size: 30),
        ),
        title: Text(
          driver.businessName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                const SizedBox(width: 4),
                Text(driver.rating.toStringAsFixed(1)),
                const SizedBox(width: 10),
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text('${driver.safariDurationHours} hrs'),
              ],
            ),
            Text(
              '${driver.locationInfo}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${driver.pricePerSafari.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: driver.isOpenNow
                    ? Colors.green.shade500
                    : Colors.red.shade500,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                driver.isOpenNow ? 'Open Now' : 'Closed',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
