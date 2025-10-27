import 'package:flutter/material.dart';
import 'package:rootrails/models/driver.dart';
import 'package:rootrails/pages/general_user/reservation_page.dart';

class DriverDetailPage extends StatelessWidget {
  final Driver driver;
  final String parkName;

  const DriverDetailPage({
    super.key,
    required this.driver,
    required this.parkName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(driver.businessName)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver/Business Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(driver.driverImageUrl),
                        onBackgroundImageError: (e, s) =>
                            const Icon(Icons.person, size: 60),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        driver.businessName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      _buildRatingRow(),
                      const SizedBox(height: 10),
                      Text(
                        'Location: ${driver.locationInfo}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Duration: ${driver.safariDurationHours} hours',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 40),

                // Detailed Info
                Text(
                  'Safari Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  context,
                  Icons.price_change,
                  'Base Price',
                  '\$${driver.pricePerSafari.toStringAsFixed(2)} per booking',
                  Colors.green,
                ),
                _buildInfoTile(
                  context,
                  Icons.verified,
                  'Service Type',
                  'Private Guided Safari in $parkName',
                  Colors.blue,
                ),
                _buildInfoTile(
                  context,
                  Icons.access_time_filled,
                  'Availability Status',
                  driver.isOpenNow
                      ? 'Available for booking today.'
                      : 'Currently closed, check back later.',
                  driver.isOpenNow ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  'About the Driver',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Experienced guide with over 10 years in the region. Specializing in finding the 'Big Five' and providing a comfortable, ethical safari experience.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 100), // Space for the floating button
              ],
            ),
          ),

          // Floating Reserve Now Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: driver.isOpenNow
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReservationPage(
                              driver: driver,
                              parkName: parkName,
                            ),
                          ),
                        );
                      }
                    : null, // Disable button if closed
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  driver.isOpenNow
                      ? 'Reserve Now - \$${driver.pricePerSafari.toStringAsFixed(2)}'
                      : 'Unavailable',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < driver.rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
