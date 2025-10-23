import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_button.dart';
import 'package:rootrails/components/cards/my_textfield.dart';

class BusinessLoginPage extends StatefulWidget {
  final VoidCallback onTap; // toggle to register page
  const BusinessLoginPage({super.key, required this.onTap});

  @override
  State<BusinessLoginPage> createState() => _BusinessLoginPageState();
}

class _BusinessLoginPageState extends State<BusinessLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _loading = false;

  void loginBusiness() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _show('Please enter email and password.');
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate to business home
      if (context.mounted) Navigator.pushReplacementNamed(context, '/business_home');
    } on FirebaseAuthException catch (e) {
      _show('Error: ${e.message}');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _show(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(title: Text(message)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTextfield(controller: emailController, hintText: 'Email', obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: passwordController, hintText: 'Password', obscureText: true),
            const SizedBox(height: 18),
            _loading
                ? const CircularProgressIndicator()
                : MyButton(onTap: loginBusiness, text: 'Login'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don’t have an account? '),
                GestureDetector(
                  onTap: widget.onTap, // toggle to register
                  child: const Text(
                    'Register Now',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
