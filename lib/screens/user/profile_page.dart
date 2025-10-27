import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _loading = true;
  Map<String, dynamic> _data = {};

  final _username = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _fire.collection('users').doc(uid).get();
    _data = doc.data() ?? {};
    _username.text = _data['user_name'] ?? '';
    _first.text = _data['first_name'] ?? '';
    _last.text = _data['last_name'] ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _fire.collection('users').doc(uid).update({
      'user_name': _username.text.trim(),
      'first_name': _first.text.trim(),
      'last_name': _last.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    child: Text(
                      (_data['user_name'] ?? 'U').toString().isEmpty
                          ? 'U'
                          : (_data['user_name'][0] ?? 'U'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _username,
                    decoration: const InputDecoration(labelText: 'User name'),
                  ),
                  TextField(
                    controller: _first,
                    decoration: const InputDecoration(labelText: 'First name'),
                  ),
                  TextField(
                    controller: _last,
                    decoration: const InputDecoration(labelText: 'Last name'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ),
    );
  }
}
