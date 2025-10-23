import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_button.dart';

class BusinessBookingsPage extends StatelessWidget {
  final String businessId;
  final String businessName;

  const BusinessBookingsPage({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$businessName Bookings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Bookings')
            .where('businessId', isEqualTo: businessId)
            .orderBy('bookingDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final bookings = snapshot.data!.docs;
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final bookingDate = (b['bookingDate'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('Customer: ${b['customerName'] ?? 'Unknown'}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${bookingDate.toLocal()}'),
                      Text('Status: ${b['status'] ?? 'Pending'}'),
                    ],
                  ),
                  trailing: MyButton(
                    text: 'Mark Done',
                    onTap: () async {
                      if (b['status'] == 'Completed') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Already completed!')),
                        );
                        return;
                      }
                      await FirebaseFirestore.instance
                          .collection('Bookings')
                          .doc(b.id)
                          .update({'status': 'Completed'});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking marked as completed!')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
