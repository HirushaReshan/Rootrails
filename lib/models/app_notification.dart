// lib/models/app_notification.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String toUserId;
  final String type;
  final String message;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.toUserId,
    required this.type,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      toUserId: d['toUserId'] ?? '',
      type: d['type'] ?? '',
      message: d['message'] ?? '',
      read: d['read'] ?? false,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }
}
