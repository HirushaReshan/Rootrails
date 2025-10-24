import 'package:flutter/material.dart';
import 'business_register.dart';
import '../../user/user_home.dart';
import '../../../services/firebase_service.dart';

class BusinessLogin extends StatefulWidget {
  const BusinessLogin({super.key});

  @override
  State<BusinessLogin> createState() => _BusinessLoginState();
}

class _BusinessLoginState extends State<BusinessLogin> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await FirebaseService.signInWithEmail(_email.text.trim(), _pass.text.trim());
      // For now navigate to BusinessHome which you will implement later
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Login')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _login, child: const Text('Login')),
          const SizedBox(height: 12),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessRegister())), child: const Text('Register Business'))
        ]),
      ),
    );
  }
}
