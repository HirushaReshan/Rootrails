// lib/pages/auth/user_register_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_button.dart';
import 'package:rootrails/components/cards/my_textfield.dart';

class UserRegisterPage extends StatefulWidget {
  final Function()? onTap;
  const UserRegisterPage({super.key, required this.onTap});
  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool acceptedTC = false;
  bool loading = false;

  static const termsText = '''
Terms & Conditions
1. Refund: user cancellation => 80% refund of paid amount (20% fee).
2. If driver cancels => full refund.
3. By registering you accept these rules.
''';

  void showTermsDialog() {
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: const Text('Terms & Conditions'),
        content: SingleChildScrollView(child: Text(termsText)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      );
    });
  }

  Future<void> register() async {
    if (!acceptedTC) return _show('Please accept Terms & Conditions');
    if (passwordController.text != confirmPasswordController.text) return _show('Passwords do not match');
    setState(() => loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text);
      await FirebaseFirestore.instance.collection('Users').doc(cred.user!.uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'accountType': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) Navigator.pushReplacementNamed(context, '/user_home');
    } on FirebaseAuthException catch (e) {
      _show('Error: ${e.code}');
    } finally {
      setState(() => loading = false);
    }
  }

  void _show(String msg) => showDialog(context: context, builder: (_) => AlertDialog(title: Text(msg)));

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register - User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          MyTextfield(controller: firstNameController, hintText: 'First name', obscureText: false),
          const SizedBox(height: 8),
          MyTextfield(controller: lastNameController, hintText: 'Last name', obscureText: false),
          const SizedBox(height: 8),
          MyTextfield(controller: emailController, hintText: 'Email', obscureText: false),
          const SizedBox(height: 8),
          MyTextfield(controller: passwordController, hintText: 'Password', obscureText: true),
          const SizedBox(height: 8),
          MyTextfield(controller: confirmPasswordController, hintText: 'Confirm password', obscureText: true),
          const SizedBox(height: 12),
          Row(children: [
            Checkbox(value: acceptedTC, onChanged: (v) => setState(() => acceptedTC = v ?? false)),
            Expanded(child: GestureDetector(onTap: showTermsDialog, child: const Text('I accept the Terms & Conditions'))),
          ]),
          const SizedBox(height: 12),
          loading ? const CircularProgressIndicator() : MyButton(onTap: register, text: 'Register'),
          const SizedBox(height: 12),
          GestureDetector(onTap: widget.onTap, child: const Text('Already have account? Login')),
        ]),
      ),
    );
  }
}
