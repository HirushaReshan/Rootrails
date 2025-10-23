// lib/pages/business/business_earnings_page.dart
import 'package:flutter/material.dart';
import 'package:rootrails/models/booking.dart';
import 'package:rootrails/services/firestore_service.dart';

class BusinessEarningsPage extends StatelessWidget {
  final String businessId;
  const BusinessEarningsPage({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: StreamBuilder<List<Booking>>(
        stream: fs.streamBookingsByBusiness(businessId),
        builder: (c, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final bookings = snap.data!;
          final completed = bookings
              .where((b) => b.status == 'completed')
              .toList();
          final total =
              completed.length *
              1000; // placeholder price per booking; replace with real price field if available
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total earnings: LKR $total',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Completed bookings:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: completed.length,
                    itemBuilder: (context, i) {
                      final b = completed[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text('At ${b.dateTime}'),
                          subtitle: Text('User: ${b.userId}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
