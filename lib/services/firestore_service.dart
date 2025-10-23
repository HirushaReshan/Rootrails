// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getDoc(String path, String id) =>
      _db.collection(path).doc(id).get();

  Future<List<QueryDocumentSnapshot>> getCollection(String path) async {
    final snap = await _db.collection(path).get();
    return snap.docs;
  }

  Future<QuerySnapshot> query(String path, String field, dynamic value) {
    return _db.collection(path).where(field, isEqualTo: value).get();
  }

  Future<void> create(String path, Map<String, dynamic> data) =>
      _db.collection(path).add(data);
  Future<DocumentReference> createAndReturnRef(
    String path,
    Map<String, dynamic> data,
  ) => _db.collection(path).add(data).then((r) => r);
  Future<void> update(String path, String id, Map<String, dynamic> data) =>
      _db.collection(path).doc(id).update(data);
}
