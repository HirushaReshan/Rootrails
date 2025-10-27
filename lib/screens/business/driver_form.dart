import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverForm extends StatefulWidget {
  final String? driverId;
  const DriverForm({super.key, this.driverId});

  @override
  State<DriverForm> createState() => _DriverFormState();
}

class _DriverFormState extends State<DriverForm> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _name = TextEditingController();
  final _image = TextEditingController();
  final _price = TextEditingController();
  final _rating = TextEditingController(text: '4.0');
  final _bio = TextEditingController();
  bool _open = true;
  bool _loading = true;
  List<String> _selectedParkIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.driverId != null)
      _load();
    else
      _loading = false;
  }

  Future<void> _load() async {
    final doc = await _fire.collection('drivers').doc(widget.driverId).get();
    final data = doc.data() ?? {};
    _name.text = data['name'] ?? '';
    _image.text = data['imageUrl'] ?? '';
    _price.text = (data['price'] ?? '').toString();
    _rating.text = (data['rating'] ?? '4.0').toString();
    _bio.text = data['bio'] ?? '';
    _open = data['open'] ?? true;
    _selectedParkIds = List<String>.from(data['parkIds'] ?? []);
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final data = {
      'name': _name.text.trim(),
      'imageUrl': _image.text.trim(),
      'price': double.tryParse(_price.text) ?? 0,
      'rating': double.tryParse(_rating.text) ?? 4.0,
      'bio': _bio.text.trim(),
      'open': _open,
      'businessId': uid,
      'parkIds': _selectedParkIds,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (widget.driverId == null) {
      await _fire.collection('drivers').add(data);
    } else {
      await _fire.collection('drivers').doc(widget.driverId).update(data);
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Driver saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.driverId == null ? 'Add Driver' : 'Edit Driver'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _image,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _price,
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _rating,
                    decoration: const InputDecoration(labelText: 'Rating'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bio,
                    decoration: const InputDecoration(labelText: 'Short bio'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Open for bookings'),
                    value: _open,
                    onChanged: (v) => setState(() => _open = v),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Assign to parks',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: _fire.collection('parks').snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData)
                        return const CircularProgressIndicator();
                      final parks = snap.data!.docs;
                      return Wrap(
                        spacing: 8,
                        children: parks.map((p) {
                          final pid = p.id;
                          final name = p['name'] ?? 'Park';
                          final selected = _selectedParkIds.contains(pid);
                          return FilterChip(
                            label: Text(name),
                            selected: selected,
                            onSelected: (v) {
                              setState(() {
                                if (v)
                                  _selectedParkIds.add(pid);
                                else
                                  _selectedParkIds.remove(pid);
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ),
    );
  }
}
