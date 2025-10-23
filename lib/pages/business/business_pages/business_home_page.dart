import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/app_bar_with_notifications.dart';
import 'package:rootrails/models/booking.dart';
import 'package:rootrails/services/firestore_service.dart';

class BusinessHomePage extends StatelessWidget {
  final String businessId;
  const BusinessHomePage({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBarWithNotifications(title: 'Dashboard', userId: businessId),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Booking>>(
                stream: fs.streamBookingsByBusiness(businessId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No bookings'));
                  }

                  final bookings = snapshot.data!;

                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final b = bookings[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text('At ${b.dateTime}'),
                          subtitle: Text('User: ${b.userId}\nStatus: ${b.status}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (b.status == 'pending')
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () async {
                                    await fs.updateBookingStatus(b.id, 'confirmed');
                                    await fs.addNotification({
                                      'toUserId': b.userId,
                                      'type': 'booking_confirmed',
                                      'message': 'Your booking is confirmed',
                                      'read': false,
                                      'createdAt': DateTime.now(),
                                    });
                                  },
                                ),
                              if (b.status == 'pending')
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () async {
                                    await fs.updateBookingStatus(b.id, 'canceled');
                                    await fs.addNotification({
                                      'toUserId': b.userId,
                                      'type': 'booking_canceled',
                                      'message': 'Your booking was canceled',
                                      'read': false,
                                      'createdAt': DateTime.now(),
                                    });
                                  },
                                ),
                              if (b.status == 'confirmed')
                                IconButton(
                                  icon: const Icon(Icons.flag, color: Colors.blue),
                                  onPressed: () async {
                                    await fs.completeBooking(b.id);
                                    await fs.addNotification({
                                      'toUserId': b.userId,
                                      'type': 'safari_completed',
                                      'message': 'Your safari was completed — please rate',
                                      'read': false,
                                      'createdAt': DateTime.now(),
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
