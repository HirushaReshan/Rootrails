import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rootrails/models/booking.dart';
import 'package:rootrails/services/booking_service.dart';

class BusinessOrdersPage extends StatelessWidget {
  const BusinessOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view your orders.'));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const TabBar(
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: [
            Tab(text: 'Pending', icon: Icon(Icons.access_time)),
            Tab(text: 'Confirmed', icon: Icon(Icons.check_circle)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
        body: TabBarView(
          children: [
            // Pass the correct status LIST to the builder function
            _buildOrderList(user.uid, ['pending']),
            _buildOrderList(user.uid, ['confirmed']),
            _buildOrderList(user.uid, ['completed', 'canceled']),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(
    String driverId,
    List<String> statuses,
  ) {
    final bool isHistory = statuses.length > 1;

    return StreamBuilder<List<Booking>>(
      stream: BookingService().getDriverOrdersByStatus(driverId, statuses),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${snapshot.error}\n\n(Have you created the Firestore index? Run the app and click the link in your console.)',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          final String statusText = isHistory ? 'history' : statuses.first;
          return Center(
            child: Text(
              'No $statusText orders found.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final orders = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return OrderCard(booking: orders[index], isHistory: isHistory);
          },
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Booking booking;
  final bool isHistory;
  const OrderCard({super.key, required this.booking, this.isHistory = false});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange.shade700;
      case 'canceled':
        return Colors.red;
      case 'completed':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      await BookingService().updateBookingStatus(booking.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Client: ${booking.userFullName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(),

            _buildDetailRow(Icons.location_on, 'Park:', booking.parkName),
            _buildDetailRow(
              Icons.calendar_month,
              'Date:',
              DateFormat('EEE, MMM d, yyyy').format(booking.bookingDate),
            ),
            _buildDetailRow(Icons.access_time, 'Time:', booking.bookingTime),
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

            if (!isHistory && booking.status == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _updateStatus(context, 'canceled'),
                    child: const Text(
                      'REJECT',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _updateStatus(context, 'confirmed'),
                    child: const Text('CONFIRM'),
                  ),
                ],
              ),

            if (!isHistory && booking.status == 'confirmed')
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('MARK COMPLETE'),
                  onPressed: () => _updateStatus(context, 'completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$title ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
