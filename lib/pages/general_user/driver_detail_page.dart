import 'package:flutter/material.dart';
import 'package:rootrails/models/driver.dart';
import 'package:rootrails/pages/general_user/reservation_page.dart';

class DriverDetailPage extends StatelessWidget {
  final Driver driver;
  final String parkName; // Passed from ParkDetailPage for the booking context

  const DriverDetailPage({
    super.key,
    required this.driver,
    required this.parkName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(driver.businessName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Image Header
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(driver.driverImageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  driver.businessName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailTile(
                    context,
                    Icons.location_on,
                    'Pickup Location',
                    driver.locationInfo.isEmpty ? 'N/A' : driver.locationInfo,
                  ),
                  _buildDetailTile(
                    context,
                    Icons.access_time,
                    'Duration',
                    '${driver.safariDurationHours} Hours',
                  ),
                  _buildDetailTile(
                    context,
                    Icons.monetization_on,
                    'Price',
                    '\$${driver.pricePerSafari.toStringAsFixed(2)} per trip',
                  ),
                  _buildDetailTile(
                    context,
                    Icons.star,
                    'Rating',
                    '${driver.rating.toStringAsFixed(1)} Stars',
                  ),

                  const Divider(height: 40),

                  Text(
                    'About the Service',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    driver.businessDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.calendar_month),
          label: const Text('Reserve Now', style: TextStyle(fontSize: 18)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReservationPage(driver: driver, parkName: parkName),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width - 100,
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
