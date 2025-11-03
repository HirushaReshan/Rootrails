import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/park.dart';
import 'package:rootrails/models/driver.dart';
import 'package:rootrails/pages/general_user/driver_detail_page.dart';

class ParkDetailPage extends StatelessWidget {
  final Park park;
  const ParkDetailPage({super.key, required this.park});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(park.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Park Header Image
            Image.network(
              park.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Park Info Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Safari Drivers',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Driver List Section
                  _buildDriverList(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('drivers')
          .where('park_id', isEqualTo: park.id) // Filter by park
          .where('is_open', isEqualTo: true) // Filter by online status
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error fetching drivers: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No drivers are currently online for this park. Please check back later.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
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
            return DriverCard(driver: drivers[index], parkName: park.name);
          },
        );
      },
    );
  }
}

class DriverCard extends StatelessWidget {
  final Driver driver;
  final String parkName;

  const DriverCard({super.key, required this.driver, required this.parkName});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(driver.driverImageUrl),
          onBackgroundImageError: (e, s) => const Icon(Icons.person),
        ),
        title: Text(
          driver.businessName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade700, size: 16),
                Text(' ${driver.rating.toStringAsFixed(1)}'),
                const SizedBox(width: 10),
                Icon(Icons.access_time, color: Colors.grey.shade600, size: 16),
                Text(' ${driver.safariDurationHours} hrs'),
              ],
            ),
            Text('Pickup: ${driver.locationInfo}'),
          ],
        ),
        trailing: Text(
          '\$${driver.pricePerSafari.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
          ),
        ),
        isThreeLine: true,
        onTap: () {
          // Navigates to existing driver_detail_page.dart
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DriverDetailPage(driver: driver, parkName: parkName),
            ),
          );
        },
      ),
    );
  }
}
