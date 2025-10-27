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
                    park.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 4),
                      Text('${park.rating.toStringAsFixed(1)} Rating'),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      Text(park.location),
                    ],
                  ),
                  const Divider(height: 30),
                  Text(
                    'Available Safari Drivers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),

                  // Driver List Section
                  _buildDriverList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverList() {
    // Assuming the 'parks' collection contains documents which are driver listings,
    // and we filter by drivers who are 'open' and associated with a park (in a real scenario, this filter would be more complex).
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parks')
          .where('business_type', isEqualTo: 'park') // Only show drivers
          .where('is_open', isEqualTo: true) // Only show active drivers
          // .where('park_id', isEqualTo: park.id) // Filter by park ID (if implemented)
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
          return const Text(
            'No drivers are currently available for booking at this park.',
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
        ),
        title: Text(
          driver.businessName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: \$${driver.pricePerSafari.toStringAsFixed(2)}'),
            Text('Duration: ${driver.safariDurationHours} hours'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
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
