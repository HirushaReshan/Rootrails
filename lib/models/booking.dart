import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String driverId;
  final String driverName;
  final String parkName;
  final DateTime bookingDate;
  final String bookingTime;
  final double totalAmount;
  final String notes;
  final String status; // 'pending', 'confirmed', 'canceled', 'completed'

  Booking({
    required this.id,
    required this.userId,
    required this.driverId,
    required this.driverName,
    required this.parkName,
    required this.bookingDate,
    required this.bookingTime,
    required this.totalAmount,
    required this.notes,
    this.status = 'pending',
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) throw Exception("Booking data not available.");

    return Booking(
      id: doc.id,
      userId: data['user_id'] ?? '',
      driverId: data['driver_id'] ?? '',
      driverName: data['driver_name'] ?? 'N/A',
      parkName: data['park_name'] ?? 'N/A',
      bookingDate: (data['booking_date'] as Timestamp).toDate(),
      bookingTime: data['booking_time'] ?? 'N/A',
      totalAmount: (data['total_amount'] as num?)?.toDouble() ?? 0.0,
      notes: data['notes'] ?? '',
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'driver_id': driverId,
      'driver_name': driverName,
      'park_name': parkName,
      'booking_date': Timestamp.fromDate(bookingDate),
      'booking_time': bookingTime,
      'total_amount': totalAmount,
      'notes': notes,
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
