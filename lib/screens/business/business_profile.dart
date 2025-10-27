import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessProfile extends StatefulWidget {
  const BusinessProfile({super.key});

  @override
  State<BusinessProfile> createState() => _BusinessProfileState();
}

class _BusinessProfileState extends State<BusinessProfile> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _image = TextEditingController();
  final _driverImage = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController();
  final _location = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _fire.collection('businesses').doc(uid).get();
    final data = doc.data() ?? {};
    _name.text = data['business_name'] ?? '';
    _desc.text = data['description'] ?? '';
    _image.text = data['imageUrl'] ?? '';
    _driverImage.text = data['driverImageUrl'] ?? '';
    _price.text = (data['price'] ?? '').toString();
    _duration.text = data['duration'] ?? '';
    _location.text = data['location'] ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _fire.collection('businesses').doc(uid).update({
      'business_name': _name.text.trim(),
      'description': _desc.text.trim(),
      'imageUrl': _image.text.trim(),
      'driverImageUrl': _driverImage.text.trim(),
      'price': double.tryParse(_price.text) ?? 0,
      'duration': _duration.text.trim(),
      'location': _location.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Business updated')));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Business')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Business name',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _desc,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _image,
                    decoration: const InputDecoration(
                      labelText: 'Business image URL',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _driverImage,
                    decoration: const InputDecoration(
                      labelText: 'Default driver image URL',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _price,
                    decoration: const InputDecoration(
                      labelText: 'Default price',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _duration,
                    decoration: const InputDecoration(
                      labelText: 'Duration (e.g. 3 hours)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _location,
                    decoration: const InputDecoration(
                      labelText: 'Location (maps url or lat,lng)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ),
    );
  }
}
