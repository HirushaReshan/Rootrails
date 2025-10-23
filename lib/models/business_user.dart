// lib/models/business_user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessUser {
  final String uid;
  final String businessName;
  final String description;
  final String imageUrl;
  final List<String> parkIds;
  final bool isOpen;
  final int avgSafariTimeMinutes;

  BusinessUser({
    required this.uid,
    required this.businessName,
    required this.description,
    required this.imageUrl,
    required this.parkIds,
    required this.isOpen,
    required this.avgSafariTimeMinutes,
  });

  factory BusinessUser.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BusinessUser(
      uid: doc.id,
      businessName: d['businessName'] ?? '',
      description: d['businessDescription'] ?? '',
      imageUrl: d['imageUrl'] ?? '',
      parkIds: List<String>.from(d['parkIds'] ?? []),
      isOpen: d['isOpen'] ?? true,
      avgSafariTimeMinutes: d['avgSafariTimeMinutes'] ?? 120,
    );
  }
}
