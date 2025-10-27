import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rootrails/models/booking.dart';

class BusinessOrdersPage extends StatelessWidget {
  const BusinessOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Log in to view orders.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: StreamBuilder<QuerySnapshot>(
        // Fetch bookings where the driverId matches the current user's UID
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('driver_id', isEqualTo: user.uid)
            .orderBy('booking_date', descending: false)
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
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  'You have no current orders. Ensure your business is OPEN to receive bookings!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final bookings = snapshot.data!.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return DriverBookingCard(booking: bookings[index]);
            },
          );
        },
      ),
    );
  }
}

class DriverBookingCard extends StatelessWidget {
  final Booking booking;
  const DriverBookingCard({super.key, required this.booking});

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

  // Function to update the booking status in Firestore
  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking.id)
          .update({
            'status': newStatus,
            'updated_at': FieldValue.serverTimestamp(),
          });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $newStatus.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
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
                  'Booking ID: ${booking.id.substring(0, 8)}...',
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
              Icons.person,
              'Customer UID:',
              booking.userId.substring(0, 10),
            ),
            _buildDetailRow(
              Icons.calendar_today,
              'Date:',
              formatter.format(booking.bookingDate),
            ),
            _buildDetailRow(Icons.access_time, 'Time:', booking.bookingTime),
            _buildDetailRow(Icons.location_on, 'Park:', booking.parkName),
            _buildDetailRow(
              Icons.attach_money,
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

            // Action Buttons
            if (booking.status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Accept',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => _updateStatus(context, 'confirmed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text(
                          'Reject',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () => _updateStatus(context, 'canceled'),
                      ),
                    ),
                  ],
                ),
              )
            else if (booking.status == 'confirmed')
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.done_all, color: Colors.white),
                    label: const Text(
                      'Mark as Completed',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _updateStatus(context, 'completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
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
          Flexible(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
