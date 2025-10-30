import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _bookingsCollection = FirebaseFirestore.instance
      .collection('bookings');

  // 1. Create a new booking
  Future<void> createBooking(Booking booking) async {
    try {
      await _bookingsCollection.doc().set(booking.toFirestore());
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // 2. Stream user's bookings (for General User: MyListPage)
  Stream<List<Booking>> getUserBookings(String userId) {
    return _bookingsCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();
        });
  }

  // 3. Stream driver's orders (FIXED for BusinessOrdersPage)
  Stream<List<Booking>> getDriverOrdersByStatus(
    String driverId,
    List<String> statuses,
  ) {
    // This query requires a composite index in Firestore
    Query query = _bookingsCollection
        .where('driver_id', isEqualTo: driverId)
        .where('status', whereIn: statuses) // Filter in the query
        .orderBy('booking_date', descending: true); // Sort by booking date

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
    });
  }

  // 4. Cancel a booking (update status to 'canceled')
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
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
      await _bookingsCollection.doc(bookingId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }
}
