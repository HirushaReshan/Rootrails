// lib/models/park.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Park {
  final String id;
  final String name;

  Park({required this.id, required this.name});

  factory Park.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Park(id: doc.id, name: d['name'] ?? '');
  }
}
