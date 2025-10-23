// lib/pages/business/business_profile_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusinessProfilePage extends StatefulWidget {
  final String businessId;
  const BusinessProfilePage({super.key, required this.businessId});
  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final _db = FirebaseFirestore.instance;
  bool loading = true;
  Map<String, dynamic> data = {};

  Future<void> load() async {
    final doc = await _db
        .collection('Business_Users')
        .doc(widget.businessId)
        .get();
    data = doc.data() ?? {};
    setState(() => loading = false);
  }

  Future<void> toggleOpen(bool value) async {
    await _db.collection('Business_Users').doc(widget.businessId).update({
      'isOpen': value,
    });
    setState(() => data['isOpen'] = value);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Business name',
                      hintText: data['businessName'] ?? '',
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Open to accept bookings'),
                      const Spacer(),
                      Switch(
                        value: data['isOpen'] ?? true,
                        onChanged: (v) => toggleOpen(v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
