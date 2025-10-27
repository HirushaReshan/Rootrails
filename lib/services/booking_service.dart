import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rootrails/models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new booking entry after successful payment
  Future<void> createBooking(Booking booking) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw Exception("User must be logged in to create a booking.");
    }

    try {
      await _firestore.collection('bookings').add(booking.toFirestore());
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // General User: Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'canceled',
        'canceled_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Stream future bookings for a General User
  Stream<List<Booking>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('user_id', isEqualTo: userId)
        .orderBy('booking_date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList(),
        );
  }
}
