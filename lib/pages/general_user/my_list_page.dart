import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rootrails/models/booking.dart';
import 'package:rootrails/services/booking_service.dart';

class MyListPage extends StatelessWidget {
  const MyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to see your bookings.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Safaris & Bookings')),
      body: StreamBuilder<List<Booking>>(
        stream: BookingService().getUserBookings(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  'You have no active or past bookings. Explore parks and drivers to get started!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return BookingCard(booking: bookings[index]);
            },
          );
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  const BookingCard({super.key, required this.booking});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      case 'completed':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  // Logic to handle cancellation
  Future<void> _cancelBooking(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: Text(
          'Are you sure you want to cancel your booking with ${booking.driverName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await BookingService().cancelBooking(booking.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking successfully canceled.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to cancel: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('EEE, MMM d, y');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.driverName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow(
              Icons.calendar_today,
              'Date:',
              formatter.format(booking.bookingDate),
            ),
            _buildDetailRow(Icons.access_time, 'Time:', booking.bookingTime),
            _buildDetailRow(Icons.location_on, 'Park:', booking.parkName),
            _buildDetailRow(
              Icons.money,
              'Amount:',
              '\$${booking.totalAmount.toStringAsFixed(2)}',
            ),

            if (booking.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Notes: ${booking.notes}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),

            if (booking.status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      'Cancel Booking',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () => _cancelBooking(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Text(value),
        ],
      ),
    );
  }
}
