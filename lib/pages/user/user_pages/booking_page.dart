import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_textfield.dart';
import 'package:rootrails/components/cards/my_button.dart';

class BookingPage extends StatefulWidget {
  final String businessId;
  const BookingPage({super.key, required this.businessId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final timeController = TextEditingController();
  bool _loading = false;

  void bookBusiness() async {
    if (timeController.text.isEmpty) return _show('Enter a valid time');

    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    final userName = userDoc['name'] ?? 'Unknown';

    try {
      await FirebaseFirestore.instance.collection('Bookings').add({
        'userId': uid,
        'userName': userName,
        'businessId': widget.businessId,
        'time': timeController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _show('Booking Successful!');
      timeController.clear();
    } catch (e) {
      _show('Failed to book: $e');
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
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book This Business')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MyTextfield(controller: timeController, hintText: 'Enter Time (e.g. 10:00 AM)', obscureText: false),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : MyButton(onTap: bookBusiness, text: 'Book Now'),
          ],
        ),
      ),
    );
  }
}
