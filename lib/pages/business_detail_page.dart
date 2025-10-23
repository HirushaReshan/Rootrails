// lib/pages/business/business_pages/business_detail_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BusinessDetailPage extends StatefulWidget {
  final String parkId;
  final Map<String, dynamic> parkData;
  final String businessId;

  const BusinessDetailPage({
    super.key,
    required this.parkId,
    required this.parkData,
    required this.businessId,
  });

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  DateTime? _selectedDateTime;
  final _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  /// Simple dummy card payment dialog. returns paymentId or null
  Future<String?> _showPaymentDialog(int amount) async {
    String cardNumber = '';
    bool processing = false;

    return await showDialog<String?>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (c, setStateDialog) {
        return AlertDialog(
          title: const Text('Dummy Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Card number (min 12 digits)'),
                onChanged: (v) => cardNumber = v,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Text('Amount: LKR $amount'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: processing
                  ? null
                  : () async {
                      setStateDialog(() => processing = true);
                      if (cardNumber.length < 12) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid card number')));
                        setStateDialog(() => processing = false);
                        return;
                      }

                      final payment = {
                        'userId': FirebaseAuth.instance.currentUser?.uid,
                        'amount': amount,
                        'cardLast4': cardNumber.length >= 4 ? cardNumber.substring(cardNumber.length - 4) : cardNumber,
                        'status': 'paid',
                        'createdAt': FieldValue.serverTimestamp(),
                      };

                      final docRef = await FirebaseFirestore.instance.collection('Payments').add(payment);
                      Navigator.pop(context, docRef.id);
                    },
              child: processing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Pay'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _reserveBusiness() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in required')));
      return;
    }
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick date & time')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // read business doc to get rate/owner etc
      final bizSnap = await FirebaseFirestore.instance.collection('Business_Users').doc(widget.businessId).get();
      if (!bizSnap.exists) {
        throw 'Business not found';
      }
      final bizData = bizSnap.data() as Map<String, dynamic>;

      final amount = (bizData['price'] is num) ? bizData['price'] as int : int.tryParse('${bizData['price']}') ?? 0;

      // payment flow
      final paymentId = await _showPaymentDialog(amount);
      if (paymentId == null) {
        setState(() => _isProcessing = false);
        return; // user cancelled
      }

      final reservation = {
        'parkId': widget.parkId,
        'parkName': widget.parkData['name'] ?? '',
        'businessId': widget.businessId,
        'businessName': bizData['businessName'] ?? '',
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'pickUpAt': Timestamp.fromDate(_selectedDateTime!),
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'notes': _notesController.text.trim(),
        'amount': amount,
        'paymentId': paymentId,
      };

      final docRef = await FirebaseFirestore.instance.collection('Reservations').add(reservation);

      // notify the business owner
      final ownerUid = bizData['ownerUid'] ?? '';
      await FirebaseFirestore.instance.collection('Notifications').add({
        'userId': ownerUid,
        'title': 'New reservation',
        'body': 'New reservation from ${user.email ?? 'a user'} for ${widget.parkData['name'] ?? ''}',
        'data': {'reservationId': docRef.id},
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reservation requested')));

      if (context.mounted) Navigator.pop(context, {'reserved': true, 'id': docRef.id});
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reservation failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessRef = FirebaseFirestore.instance.collection('Business_Users').doc(widget.businessId);

    return Scaffold(
      appBar: AppBar(title: const Text('Business Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: businessRef.get(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || !snap.data!.exists) return const Center(child: Text('Business not found'));
          final biz = snap.data!.data() as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if ((biz['imageUrl'] ?? '').toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(biz['imageUrl'], width: double.infinity, height: 180, fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),
              Text(biz['businessName'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(biz['businessDescription'] ?? ''),
              const SizedBox(height: 12),
              Text('Price: LKR ${biz['price'] ?? 0}'),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(_selectedDateTime != null ? 'Picked: ${_selectedDateTime!.toLocal()}' : 'Pick date & time'),
                trailing: ElevatedButton(onPressed: _pickDateTime, child: const Text('Pick')),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _reserveBusiness,
                  child: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Text('Reserve & Pay'),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
