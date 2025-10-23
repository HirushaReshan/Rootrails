// lib/pages/auth/business_register_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_button.dart';
import 'package:rootrails/components/cards/my_textfield.dart';

class BusinessRegisterPage extends StatefulWidget {
  final Function()? onTap;
  BusinessRegisterPage({super.key, required this.onTap});
  @override
  State<BusinessRegisterPage> createState() => _BusinessRegisterPageState();
}

class _BusinessRegisterPageState extends State<BusinessRegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final businessNameController = TextEditingController();
  final businessDescriptionController = TextEditingController();
  final priceController = TextEditingController();
  final parkImageUrlController = TextEditingController();
  final openingTimeController = TextEditingController(text: '08:00');
  final closingTimeController = TextEditingController(text: '18:00');
  final avgTimeController = TextEditingController(text: '120');
  bool _loading = false;

  Future<void> signUserUp() async {
    if (passwordController.text != confirmPasswordController.text)
      return _show('Passwords do not match');
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final uid = cred.user!.uid;
      await FirebaseFirestore.instance
          .collection('Business_Users')
          .doc(uid)
          .set({
            'businessName': businessNameController.text.trim(),
            'businessDescription': businessDescriptionController.text.trim(),
            'email': emailController.text.trim(),
            'price': int.tryParse(priceController.text.trim()) ?? 0,
            'ownerUid': uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
      // create initial park for this business (you can remove if not needed)
      final parkRef = await FirebaseFirestore.instance.collection('Parks').add({
        'name': '${businessNameController.text.trim()} Park',
        'location': 'Not set',
        'description': businessDescriptionController.text.trim(),
        'imageUrl': parkImageUrlController.text.trim(),
        'openingTime': openingTimeController.text.trim(),
        'closingTime': closingTimeController.text.trim(),
        'avgSafariTimeMinutes':
            int.tryParse(avgTimeController.text.trim()) ?? 120,
        'businessId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance
          .collection('Business_Users')
          .doc(uid)
          .update({
            'parkIds': FieldValue.arrayUnion([parkRef.id]),
          });
      if (context.mounted)
        Navigator.pushReplacementNamed(context, '/business_home');
    } on FirebaseAuthException catch (e) {
      _show(e.code);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _show(String m) => showDialog(
    context: context,
    builder: (_) => AlertDialog(title: Text(m)),
  );

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    businessNameController.dispose();
    businessDescriptionController.dispose();
    priceController.dispose();
    parkImageUrlController.dispose();
    openingTimeController.dispose();
    closingTimeController.dispose();
    avgTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MyTextfield(
              controller: businessNameController,
              hintText: 'Business name',
              obscureText: false,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: businessDescriptionController,
              hintText: 'Description',
              obscureText: false,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: priceController,
              hintText: 'Base price (LKR)',
              obscureText: false,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: parkImageUrlController,
              hintText: 'Park image URL (optional)',
              obscureText: false,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: openingTimeController,
              hintText: 'Opening time (08:00)',
              obscureText: false,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: closingTimeController,
              hintText: 'Closing time (18:00)',
              obscureText: false,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: avgTimeController,
              hintText: 'Avg safari time (minutes)',
              obscureText: false,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: confirmPasswordController,
              hintText: 'Confirm password',
              obscureText: true,
            ),
            const SizedBox(height: 18),
            _loading
                ? const CircularProgressIndicator()
                : MyButton(onTap: signUserUp, text: 'Register Business'),
          ],
        ),
      ),
    );
  }
}
