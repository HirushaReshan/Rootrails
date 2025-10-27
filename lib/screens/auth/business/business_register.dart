import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';

class BusinessRegister extends StatefulWidget {
  const BusinessRegister({super.key});

  @override
  State<BusinessRegister> createState() => _BusinessRegisterState();
}

class _BusinessRegisterState extends State<BusinessRegister> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _image = TextEditingController();
  final _driverImage = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController();
  final _location = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (_pass.text != _confirm.text) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match'))); return; }
    setState(() => _loading = true);
    try {
      final cred = await FirebaseService.registerWithEmail(_email.text.trim(), _pass.text.trim());
      final uid = cred.user!.uid;
      await FirebaseService.createBusinessDocument(uid, {
        'business_name': _name.text.trim(),
        'description': _desc.text.trim(),
        'imageUrl': _image.text.trim(),
        'driverImageUrl': _driverImage.text.trim(),
        'price': double.tryParse(_price.text) ?? 0,
        'duration': _duration.text,
        'location': _location.text,
        'open': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Business')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Business name')),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
          TextField(controller: _image, decoration: const InputDecoration(labelText: 'Business image URL')),
          TextField(controller: _driverImage, decoration: const InputDecoration(labelText: 'Driver image URL')),
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price')),
          TextField(controller: _duration, decoration: const InputDecoration(labelText: 'Duration (e.g. 3 hours)')),
          TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location (maps url)')),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          TextField(controller: _confirm, decoration: const InputDecoration(labelText: 'Confirm Password'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _register, child: const Text('Register'))
        ]),
      ),
    );
  }
}
