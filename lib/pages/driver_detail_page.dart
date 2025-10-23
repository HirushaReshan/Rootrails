import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/pages/notifications_page.dart';

class DriverDetailPage extends StatefulWidget {
  final String parkId;
  final String parkName;
  final String driverId;
  final Map<String, dynamic> driverData;

  const DriverDetailPage({
    super.key,
    required this.parkId,
    required this.parkName,
    required this.driverId,
    required this.driverData,
  });

  @override
  State<DriverDetailPage> createState() => _DriverDetailPageState();
}

class _DriverDetailPageState extends State<DriverDetailPage> {
  DateTime? _selectedDateTime;
  final _notesController = TextEditingController();
  bool _isReserving = false;

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
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<String?> _showPaymentDialog(int amount) async {
    String cardNumber = '';
    bool processing = false;

    return await showDialog<String?>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Dummy Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                      hintText: 'Card number (e.g. 4242424242424242)'),
                  onChanged: (v) => cardNumber = v,
                ),
                const SizedBox(height: 8),
                Text('Amount: LKR $amount'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: processing
                    ? null
                    : () async {
                        setStateDialog(() => processing = true);

                        if (cardNumber.length < 12) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid card')),
                          );
                          setStateDialog(() => processing = false);
                          return;
                        }

                        final payment = {
                          'userId': FirebaseAuth.instance.currentUser?.uid,
                          'amount': amount,
                          'cardLast4': cardNumber.length >= 4
                              ? cardNumber.substring(cardNumber.length - 4)
                              : cardNumber,
                          'status': 'paid',
                          'createdAt': FieldValue.serverTimestamp(),
                        };

                        final docRef = await FirebaseFirestore.instance
                            .collection('Payments')
                            .add(payment);

                        Navigator.pop(context, docRef.id);
                      },
                child: processing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Pay'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _reserveDriver() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in required')),
      );
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick date & time')),
      );
      return;
    }

    setState(() => _isReserving = true);

    final amount = widget.driverData['ratePerHour'] ?? 0;

    final paymentId = await _showPaymentDialog(amount);
    if (paymentId == null) {
      setState(() => _isReserving = false);
      return;
    }

    final reservation = {
      'parkId': widget.parkId,
      'parkName': widget.parkName,
      'driverId': widget.driverId,
      'driverName': widget.driverData['name'] ?? '',
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'pickUpAt': Timestamp.fromDate(_selectedDateTime!),
      'requestedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'notes': _notesController.text.trim(),
      'amount': amount,
      'paymentId': paymentId,
    };

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('Reservations')
          .add(reservation);

      // Create notification for driver/business
      await FirebaseFirestore.instance.collection('Notifications').add({
        'userId': widget.driverData['ownerUid'] ?? '',
        'title': 'New reservation',
        'body': 'New reservation for ${widget.parkName}',
        'data': {'reservationId': docRef.id},
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isReserving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation requested')),
      );

      if (context.mounted) {
        Navigator.pop(context, {'reserved': true, 'id': docRef.id});
      }
    } catch (e) {
      setState(() => _isReserving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.driverData;

    return Scaffold(
      appBar: AppBar(
        title: Text(d['name'] ?? 'Driver'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            ),
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((d['imageUrl'] ?? '').toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  d['imageUrl'],
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              d['name'] ?? '',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Vehicle: ${d['vehicle'] ?? '-'}'),
            const SizedBox(height: 6),
            Text('Rate: ${d['ratePerHour'] ?? '-'} /hr'),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration:
                  const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text(
                _selectedDateTime != null
                    ? 'Picked: ${_selectedDateTime!.toLocal()}'
                    : 'Pick date & time',
              ),
              trailing: ElevatedButton(
                onPressed: _pickDateTime,
                child: const Text('Pick'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isReserving ? null : _reserveDriver,
                child: _isReserving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Reserve & Pay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
