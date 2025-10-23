import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rootrails/components/cards/my_button.dart';
import 'package:rootrails/components/cards/my_textfield.dart';
import 'package:rootrails/services/cloudinary_service.dart';

class BusinessRegisterPage extends StatefulWidget {
  final VoidCallback onTap; // toggle to login page
  const BusinessRegisterPage({super.key, required this.onTap});

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
  final openingTimeController = TextEditingController(text: '08:00');
  final closingTimeController = TextEditingController(text: '18:00');
  final avgTimeController = TextEditingController(text: '120');

  File? _selectedImage;
  bool _loading = false;
  final cloudinaryService = CloudinaryService();

  final Set<String> _selectedParkIds = {};

  Future pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> signUserUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      return _show('Passwords do not match');
    }
    if (businessNameController.text.trim().isEmpty) {
      return _show('Please enter business name');
    }
    if (_selectedParkIds.isEmpty) {
      return _show('Please select at least one Park to operate in');
    }

    setState(() => _loading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final uid = cred.user!.uid;

      String imageUrl = '';
      if (_selectedImage != null) {
        imageUrl = await cloudinaryService.uploadImage(_selectedImage!, 'businesses');
      }

      final businessDocRef = FirebaseFirestore.instance.collection('Business_Users').doc(uid);
      final businessData = {
        'businessName': businessNameController.text.trim(),
        'businessDescription': businessDescriptionController.text.trim(),
        'email': emailController.text.trim(),
        'price': int.tryParse(priceController.text.trim()) ?? 0,
        'ownerUid': uid,
        'imageUrl': imageUrl,
        'openingTime': openingTimeController.text.trim(),
        'closingTime': closingTimeController.text.trim(),
        'avgSafariTimeMinutes': int.tryParse(avgTimeController.text.trim()) ?? 120,
        'parkIds': _selectedParkIds.toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await businessDocRef.set(businessData);

      final batch = FirebaseFirestore.instance.batch();
      for (final parkId in _selectedParkIds) {
        final parkRef = FirebaseFirestore.instance.collection('Parks').doc(parkId);
        batch.update(parkRef, {'businessIds': FieldValue.arrayUnion([uid])});
      }
      await batch.commit();

      if (context.mounted) {
        _show('Business registered successfully!');
        Navigator.pushReplacementNamed(context, '/business_home');
      }
    } on FirebaseAuthException catch (e) {
      _show('Auth error: ${e.code}');
    } catch (e) {
      _show('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _show(String m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(m),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    businessNameController.dispose();
    businessDescriptionController.dispose();
    priceController.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: pickImage,
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, height: 120, fit: BoxFit.cover)
                  : Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(child: Text('Tap to select business image')),
                    ),
            ),
            const SizedBox(height: 12),
            MyTextfield(controller: businessNameController, hintText: 'Business name', obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: businessDescriptionController, hintText: 'Description', obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: priceController, hintText: 'Base price (LKR)', obscureText: false),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: MyTextfield(controller: openingTimeController, hintText: 'Opening time (08:00)', obscureText: false)),
                const SizedBox(width: 8),
                Expanded(child: MyTextfield(controller: closingTimeController, hintText: 'Closing time (18:00)', obscureText: false)),
              ],
            ),
            const SizedBox(height: 12),
            MyTextfield(controller: avgTimeController, hintText: 'Avg safari time (minutes)', obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: emailController, hintText: 'Email', obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: passwordController, hintText: 'Password', obscureText: true),
            const SizedBox(height: 12),
            MyTextfield(controller: confirmPasswordController, hintText: 'Confirm password', obscureText: true),
            const SizedBox(height: 18),
            const Text('Select parks you operate in:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Parks').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final parks = snap.data!.docs;
                if (parks.isEmpty) return const Text('No parks available — add parks in Firestore first.');
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: parks.map((p) {
                    final id = p.id;
                    final data = p.data() as Map<String, dynamic>;
                    final selected = _selectedParkIds.contains(id);
                    return FilterChip(
                      label: Text(data['name'] ?? 'Unnamed'),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) _selectedParkIds.add(id);
                          else _selectedParkIds.remove(id);
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 18),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : MyButton(onTap: signUserUp, text: 'Register Business'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: widget.onTap,
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
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
