import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/booking.dart';
import 'package:rootrails/models/park.dart';
import 'package:rootrails/models/app_notification.dart';
import 'package:rootrails/models/business_user.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ------------------- USERS / BUSINESSES -------------------
  Future<void> createUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('Users').doc(uid).set(data);
  }

  Future<void> createBusiness(String uid, Map<String, dynamic> data) async {
    await _db.collection('Business_Users').doc(uid).set(data);
  }

  // ------------------- BOOKINGS -------------------
  Stream<List<Booking>> streamBookingsByUser(String userId) {
    return _db
        .collection('Bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Booking.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Stream<List<Booking>> streamBookingsByBusiness(String businessId) {
    return _db
        .collection('Bookings')
        .where('businessId', isEqualTo: businessId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Booking.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('Bookings').doc(bookingId).update({'status': status});
  }

  Future<void> completeBooking(String bookingId) async {
    await _db
        .collection('Bookings')
        .doc(bookingId)
        .update({'status': 'completed', 'completedAt': FieldValue.serverTimestamp()});
  }

  Future<void> rateBooking(String bookingId, int stars, String comment) async {
    await _db.collection('Bookings').doc(bookingId).update({
      'rating': stars,
      'comment': comment,
      'ratedAt': FieldValue.serverTimestamp(),
    });
  }

  // ------------------- PARKS -------------------
  Stream<List<Park>> streamParks() {
    return _db.collection('Parks').snapshots().map(
        (snap) => snap.docs.map((doc) => Park.fromFirestore(doc.id, doc.data())).toList());
  }

  // ------------------- BUSINESSES -------------------
  Stream<List<BusinessUser>> streamBusinesses() {
    return _db.collection('Business_Users').snapshots().map((snap) =>
        snap.docs.map((doc) => BusinessUser.fromFirestore(doc.id, doc.data())).toList());
  }

  // ------------------- NOTIFICATIONS -------------------
  Stream<List<AppNotification>> streamNotifications(String userId) {
    return _db
        .collection('Notifications')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AppNotification.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<void> addNotification(Map<String, dynamic> data) async {
    await _db.collection('Notifications').add(data);
  }
}
