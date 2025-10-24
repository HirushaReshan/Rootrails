import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../user/driver_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final _fire = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Reserve')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          const Text('Select time'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['08:00', '10:00', '12:00', '14:00', '16:00'].map((t) => ChoiceChip(label: Text(t), selected: selectedTime == t, onSelected: (_) => setState(() => selectedTime = t))).toList()),
          const SizedBox(height: 12),
          ListTile(
            title: Text(selectedDate == null ? 'Select Date' : selectedDate!.toLocal().toString().split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (d != null) setState(() => selectedDate = d);
            },
          ),
          const SizedBox(height: 12),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes (optional)')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loading ? null : () async {
            if (selectedTime == null || selectedDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select time and date'))); return; }
            setState(() => _loading = true);
            // Create a simple booking doc
            await FirebaseFirestore.instance.collection('bookings').add({
              'driverId': widget.driverId,
              'userId': FirebaseFirestore.instance.app.name, // placeholder: replace with actual UID lookup
              'time': selectedTime,
              'date': selectedDate,
              'notes': _notes.text,
              'status': 'pending',
              'createdAt': FieldValue.serverTimestamp(),
            });
            // Navigate to dummy payment
            final ok = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DummyPayment()));
            if (ok == true) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created')));
              Navigator.popUntil(context, (route) => route.isFirst);
            }
            setState(() => _loading = false);
          }, child: _loading ? const CircularProgressIndicator() : const Text('Book now'))
        ]),
      ),
    );
  }
}

class DummyPayment extends StatelessWidget {
  const DummyPayment({super.key});

  @override
  Widget build(BuildContext context) {
    final _card = TextEditingController();
    final _exp = TextEditingController();
    final _cvv = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _card, decoration: const InputDecoration(labelText: 'Card number')),
          TextField(controller: _exp, decoration: const InputDecoration(labelText: 'MM/YY')),
          TextField(controller: _cvv, decoration: const InputDecoration(labelText: 'CVV')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () async {
            // Dummy simulate success
            await Future.delayed(const Duration(seconds: 1));
            Navigator.pop(context, true);
          }, child: const Text('Pay'))
        ]),
      ),
    );
  }
}
