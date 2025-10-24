import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase_service.dart';
import '../../user/user_home.dart';

class GeneralRegister extends StatefulWidget {
  const GeneralRegister({super.key});

  @override
  State<GeneralRegister> createState() => _GeneralRegisterState();
}

class _GeneralRegisterState extends State<GeneralRegister> {
  final _username = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await FirebaseService.registerWithEmail(_email.text.trim(), _password.text.trim());
      final user = cred.user!;
      await FirebaseService.createGeneralUserDocument(user.uid, {
        'user_name': _username.text.trim(),
        'first_name': _first.text.trim(),
        'last_name': _last.text.trim(),
        'email': _email.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePage()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Registration failed')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _username, decoration: const InputDecoration(labelText: 'User name')),
          TextField(controller: _first, decoration: const InputDecoration(labelText: 'First name')),
          TextField(controller: _last, decoration: const InputDecoration(labelText: 'Last name')),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          TextField(controller: _confirm, decoration: const InputDecoration(labelText: 'Confirm password'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Register')),
        ]),
      ),
    );
  }
}