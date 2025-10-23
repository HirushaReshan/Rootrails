import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String businessId;
  final DateTime dateTime;
  final String status;
  final int? rating; // nullable for pending or confirmed bookings

  Booking({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.dateTime,
    required this.status,
    this.rating,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String docId) {
    return Booking(
      id: docId,
      userId: map['userId'] ?? '',
      businessId: map['businessId'] ?? '',
      dateTime: map['dateTime'] != null
          ? (map['dateTime'] as Timestamp).toDate()
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      rating: map['rating'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'businessId': businessId,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'rating': rating,
    };
  }
}
