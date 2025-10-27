import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Create a new booking
  Future<void> createBooking(Booking booking) async {
    try {
      await _firestore.collection('bookings').add(booking.toFirestore());
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // 2. Stream user's bookings (for General User: MyListPage)
  Stream<List<Booking>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();
        });
  }

  // 3. Stream driver's orders (for Business User: BusinessOrdersPage)
  Stream<List<Booking>> getDriverOrders(String driverId) {
    // Note: BusinessOrdersPage uses a direct FirebaseFirestore call for simplicity,
    // but this function provides a cleaner service layer approach.
    return _firestore
        .collection('bookings')
        .where('driver_id', isEqualTo: driverId)
        .orderBy('booking_date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();
        });
  }

  // 4. Cancel a booking (update status to 'canceled')
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'canceled',
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // 5. Update booking status (used by driver)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      if (!['pending', 'confirmed', 'canceled', 'completed'].contains(status)) {
        throw Exception("Invalid status provided.");
      }
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }
}
