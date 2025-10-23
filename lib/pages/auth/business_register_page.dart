// lib/pages/auth/business_register_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_button.dart';
import 'package:rootrails/components/cards/my_textfield.dart';
import 'package:rootrails/widgets/business_bottom_nav.dart';
import '../../services/firestore_service.dart';


class BusinessRegisterPage extends StatefulWidget {
  const BusinessRegisterPage({super.key});
  @override
  State<BusinessRegisterPage> createState() => _BusinessRegisterPageState();
}

class _BusinessRegisterPageState extends State<BusinessRegisterPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final openingCtrl = TextEditingController(text: '08:00');
  final closingCtrl = TextEditingController(text: '18:00');
  final avgCtrl = TextEditingController(text: '120');
  final imageUrlCtrl = TextEditingController();
  final fs = FirestoreService();
  final _db = FirebaseFirestore.instance;
  bool loading = false;
  final Set<String> _selectedParkIds = {};

  Future<void> _pickParkToggle(String id) async {
    if (_selectedParkIds.contains(id))
      _selectedParkIds.remove(id);
    else
      _selectedParkIds.add(id);
  }

  Future<void> signUp() async {
  if (nameCtrl.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter business name')));
    return;
  }
  if (_selectedParkIds.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one park')));
    return;
  }

  setState(() => loading = true);
  try {
    // 1) create auth user (this also signs them in)
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailCtrl.text.trim(),
      password: passCtrl.text,
    );
    final uid = cred.user!.uid;

    // 2) prepare business data
    final data = {
      'businessName': nameCtrl.text.trim(),
      'businessDescription': descCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'price': int.tryParse(priceCtrl.text) ?? 0,
      'imageUrl': imageUrlCtrl.text.trim(),
      'openingTime': openingCtrl.text.trim(),
      'closingTime': closingCtrl.text.trim(),
      'avgSafariTimeMinutes': int.tryParse(avgCtrl.text) ?? 120,
      'parkIds': _selectedParkIds.toList(),
      'isOpen': true,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 3) write business doc (doc id = auth uid)
    await fs.createBusiness(uid, data);

    // 4) update parks to include this business id (batch)
    final batch = _db.batch();
    for (final pid in _selectedParkIds) {
      final ref = _db.collection('Parks').doc(pid);
      batch.update(ref, {
        'businessIds': FieldValue.arrayUnion([uid]),
      });
    }
    await batch.commit();

    // 5) NAVIGATE to business interface directly (avoid relying on SplashRouter)
    if (!mounted) return;
    // Replace with your business bottom nav widget import/path
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BusinessBottomNav(businessId: uid)),
    );

  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auth error: ${e.message}')));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    if (mounted) setState(() => loading = false);
  }
}


  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    openingCtrl.dispose();
    closingCtrl.dispose();
    avgCtrl.dispose();
    imageUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business (Driver) Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            MyTextfield(
              controller: nameCtrl,
              hintText: 'Business / Driver name',
              obscureText: false,
            ),
            const SizedBox(height: 8),
            MyTextfield(
              controller: descCtrl,
              hintText: 'Description',
              obscureText: false,
            ),
            const SizedBox(height: 8),
            MyTextfield(
              controller: priceCtrl,
              hintText: 'Price (LKR)',
              obscureText: false,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            MyTextfield(
              controller: imageUrlCtrl,
              hintText: 'Image URL (optional)',
              obscureText: false,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: MyTextfield(
                    controller: openingCtrl,
                    hintText: 'Open',
                    obscureText: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MyTextfield(
                    controller: closingCtrl,
                    hintText: 'Close',
                    obscureText: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Parks you operate in:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Parks')
                  .snapshots(),
              builder: (c, snap) {
                if (!snap.hasData)
                  return const Center(child: CircularProgressIndicator());
                final parks = snap.data!.docs;
                if (parks.isEmpty)
                  return const Text(
                    'No parks defined. Add parks in Firestore.',
                  );
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: parks.map((p) {
                    final id = p.id;
                    final name =
                        (p.data() as Map<String, dynamic>)['name'] ?? 'Unnamed';
                    final selected = _selectedParkIds.contains(id);
                    return FilterChip(
                      label: Text(name),
                      selected: selected,
                      onSelected: (v) => setState(
                        () => v
                            ? _selectedParkIds.add(id)
                            : _selectedParkIds.remove(id),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: emailCtrl,
              hintText: 'Email',
              obscureText: false,
            ),
            const SizedBox(height: 8),
            MyTextfield(
              controller: passCtrl,
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            loading
                ? const CircularProgressIndicator()
                : MyButton(text: 'Register Business (Driver)', onTap: signUp),
          ],
        ),
      ),
    );
  }
}
