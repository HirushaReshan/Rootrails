import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/park.dart';
import 'package:rootrails/models/driver.dart';
import 'package:rootrails/pages/general_user/driver_detail_page.dart';

class DriverListPage extends StatelessWidget {
  final Park park;
  const DriverListPage({super.key, required this.park});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drivers in ${park.name}')),
      body: StreamBuilder<QuerySnapshot>(
        // This is the core query of the new system
        stream: FirebaseFirestore.instance
            .collection('drivers') // 1. Query the 'drivers' collection
            .where(
              'park_id',
              isEqualTo: park.id,
            ) // 2. Filter by the passed park ID
            .where(
              'is_open',
              isEqualTo: true,
            ) // 3. Only show drivers who are ONLINE
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
                'No online drivers found in this park right now.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          final drivers = snapshot.data!.docs
              .map((doc) => Driver.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              return DriverCard(driver: drivers[index], parkName: park.name);
            },
          );
        },
      ),
    );
  }
}

class DriverCard extends StatelessWidget {
  final Driver driver;
  final String parkName; // We need to pass parkName to the detail page
  const DriverCard({super.key, required this.driver, required this.parkName});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      elevation: 3,
      child: ListTile(
        onTap: () {
          // Navigate to the DriverDetailPage (which you already have)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriverDetailPage(
                driver: driver,
                parkName: parkName, // Pass the parkName for the booking
              ),
            ),
          );
        },
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
            Text(driver.locationInfo),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${driver.rating.toStringAsFixed(1)}'),
                const SizedBox(width: 10),
                Icon(Icons.access_time, color: Colors.grey, size: 16),
                Text(' ${driver.safariDurationHours} hrs'),
              ],
            ),
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
      ),
    );
  }
}
