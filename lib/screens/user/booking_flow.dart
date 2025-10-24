import 'package:flutter/material.dart';
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