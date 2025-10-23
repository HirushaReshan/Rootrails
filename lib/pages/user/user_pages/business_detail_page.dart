// lib/pages/user/user_pages/business_detail_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/models/business_user.dart';
import 'package:rootrails/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessDetailPage extends StatefulWidget {
  final String businessId;
  const BusinessDetailPage({super.key, required this.businessId});
  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _loading = false;
  final fs = FirestoreService();

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t == null) return;
    setState(() {
      _selectedDate = d;
      _selectedTime = t;
    });
  }

  Future<void> _book(BusinessUser bus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in required')));
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pick date & time')));
      return;
    }

    setState(() => _loading = true);
    final dt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final bookingData = {
      'userId': user.uid,
      'businessId': bus.uid,
      'parkId': bus.parkIds.isNotEmpty ? bus.parkIds.first : '',
      'dateTime': Timestamp.fromDate(dt),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('Bookings').add(bookingData);

      // add notification to business
      await FirebaseFirestore.instance.collection('Notifications').add({
        'toUserId': bus.uid,
        'type': 'new_booking',
        'message': 'New booking requested by ${user.email}',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking requested')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create booking: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Business_Users')
          .doc(widget.businessId)
          .snapshots(),
      builder: (c, snap) {
        if (!snap.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        final doc = snap.data!;
        final business = BusinessUser.fromFirestore(doc);
        return Scaffold(
          appBar: AppBar(title: Text(business.businessName)),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (business.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      business.imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  business.businessName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(business.description),
                const SizedBox(height: 12),
                Text('Avg safari time: ${business.avgSafariTimeMinutes} min'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: const Text('Pick date & time'),
                ),
                const SizedBox(height: 8),
                if (_selectedDate != null && _selectedTime != null)
                  Text(
                    'Selected: ${_selectedDate!.toLocal()} ${_selectedTime!.format(context)}',
                  ),
                const SizedBox(height: 12),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () => _book(business),
                        child: const Text('Book'),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
