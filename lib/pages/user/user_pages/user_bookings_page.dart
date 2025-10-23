import 'package:flutter/material.dart';
import 'package:rootrails/models/booking.dart';
import 'package:rootrails/services/firestore_service.dart';
import 'rate_booking_page.dart';

class UserBookingsPage extends StatelessWidget {
  final String userId;
  const UserBookingsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder<List<Booking>>(
        stream: fs.streamBookingsByUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings yet'));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text('At ${b.dateTime}'),
                  subtitle: Text('Business: ${b.businessId}\nStatus: ${b.status}'),
                  trailing: b.status == 'completed' && b.rating == null
                      ? IconButton(
                          icon: const Icon(Icons.star, color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RateBookingPage(bookingId: b.id),
                              ),
                            );
                          },
                        )
                      : Text(b.rating != null ? 'Rated: ${b.rating}' : ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
