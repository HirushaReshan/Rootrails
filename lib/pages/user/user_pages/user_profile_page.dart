// lib/pages/user/user_profile_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final nameCtrl = TextEditingController();
  bool loading = true;

  Future<void> load() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _db.collection('Users').doc(uid).get();
    final d = doc.data();
    nameCtrl.text = (d?['name'] ?? '');
    setState(() => loading = false);
  }

  Future<void> save() async {
    final uid = _auth.currentUser!.uid;
    await _db.collection('Users').doc(uid).set({'name': nameCtrl.text.trim()}, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Profile')), body: loading ? const Center(child: CircularProgressIndicator()) : Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: save, child: const Text('Save')),
    ])));
  }
}
