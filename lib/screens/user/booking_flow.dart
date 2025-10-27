import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../payment/dummy_payment.dart';

class BookingFlow extends StatefulWidget {
  final String driverId;
  const BookingFlow({super.key, required this.driverId});

  @override
  State<BookingFlow> createState() => _BookingFlowState();
}

class _BookingFlowState extends State<BookingFlow> {
  String? selectedTime;
  DateTime? selectedDate;
  final _notes = TextEditingController();
  bool _loading = false;
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getUserDoc() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};
    final snap = await _fire.collection('users').doc(uid).get();
    return snap.data() ?? {};
  }

  Future<void> _createBooking() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to book.')),
      );
      return;
    }
    if (selectedTime == null || selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select time and date')));
      return;
    }

    setState(() => _loading = true);

    // get user info
    final userDoc = await _getUserDoc();
    final userName =
        userDoc['user_name'] ?? _auth.currentUser?.displayName ?? '';

    // get driver and business info
    final driverSnap = await _fire
        .collection('drivers')
        .doc(widget.driverId)
        .get();
    final driver = driverSnap.data() ?? {};
    final driverName = driver['name'] ?? '';
    final businessId = driver['businessId'] ?? null;
    final businessName = '';

    final bookingData = {
      'driverId': widget.driverId,
      'driverName': driverName,
      'userId': uid,
      'userName': userName,
      'businessId': businessId,
      'time': selectedTime,
      'date': Timestamp.fromDate(
        DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day),
      ),
      'notes': _notes.text.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _fire.collection('bookings').add(bookingData);

    // Create an in-app notification document for the business (optional)
    if (businessId != null) {
      await _fire.collection('notifications').add({
        'to': businessId,
        'type': 'new_booking',
        'bookingId': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    }

    // Proceed to payment screen (dummy). If payment succeeds, update booking status to 'confirmed'
    final paid = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DummyPayment()),
    );
    if (paid == true) {
      await _fire.collection('bookings').doc(docRef.id).update({
        'status': 'confirmed',
        'paidAt': FieldValue.serverTimestamp(),
      });
    }

    setState(() => _loading = false);

    // goto home or show success
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking created')));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reserve')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text('Select time'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['08:00', '10:00', '12:00', '14:00', '16:00']
                  .map(
                    (t) => ChoiceChip(
                      label: Text(t),
                      selected: selectedTime == t,
                      onSelected: (_) => setState(() => selectedTime = t),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text(
                selectedDate == null
                    ? 'Select Date'
                    : DateFormat.yMMMd().format(selectedDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => selectedDate = d);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _createBooking,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Book now'),
            ),
          ],
        ),
      ),
    );
  }
}
