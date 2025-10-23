import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_textfield.dart';
import 'package:rootrails/components/cards/my_button.dart';

class UserRegisterPage extends StatefulWidget {
  final Function()? onTap; // allows toggling to login
  const UserRegisterPage({super.key, required this.onTap});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _loading = false;

  void registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      return _showError('Passwords do not match');
    }

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('Users').doc(cred.user!.uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) Navigator.pushReplacementNamed(context, '/user_home');
    } on FirebaseAuthException catch (e) {
      _showError(e.code);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) => showDialog(
        context: context,
        builder: (_) => AlertDialog(title: Text(msg)),
      );

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MyTextfield(controller: nameController, hintText: 'Full Name', obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: emailController, hintText: 'Email', obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: passwordController, hintText: 'Password', obscureText: true),
            const SizedBox(height: 12),
            MyTextfield(controller: confirmPasswordController, hintText: 'Confirm Password', obscureText: true),
            const SizedBox(height: 18),
            _loading
                ? const CircularProgressIndicator()
                : MyButton(onTap: registerUser, text: 'Register'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already a member? '),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    'Login Now',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
