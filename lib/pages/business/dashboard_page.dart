import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/app_bar_with_notifications.dart';
import '../../services/firestore_service.dart';
import '../../models/booking.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final businessId =
        'CURRENT_LOGGED_IN_BUSINESS_UID'; // replace with auth user id
    return Scaffold(
      appBar: AppBarWithNotifications(userId: businessId, title: 'Dashboard'),
      body: StreamBuilder<List<Booking>>(
        stream: FirestoreService().streamBookingsByBusiness(businessId),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final bookings = snapshot.data!;
          if (bookings.isEmpty) return const Center(child: Text('No bookings'));
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return ListTile(
                title: Text('Booking for ${b.userId} at ${b.dateTime}'),
                subtitle: Text('Status: ${b.status}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (b.status == 'pending')
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await FirestoreService().updateBookingStatus(
                            b.id,
                            'confirmed',
                          );
                          await FirestoreService().addNotification({
                            'toUserId': b.userId,
                            'type': 'booking_confirmed',
                            'message': 'Your booking is confirmed!',
                            'read': false,
                            'createdAt': DateTime.now(),
                          });
                        },
                      ),
                    if (b.status == 'pending')
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await FirestoreService().updateBookingStatus(
                            b.id,
                            'canceled',
                          );
                          await FirestoreService().addNotification({
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
                          await FirestoreService().updateBookingStatus(
                            b.id,
                            'completed',
                          );
                          await FirestoreService().addNotification({
                            'toUserId': b.userId,
                            'type': 'safari_completed',
                            'message':
                                'Your safari is completed! Please rate your experience.',
                            'read': false,
                            'createdAt': DateTime.now(),
                          });
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
