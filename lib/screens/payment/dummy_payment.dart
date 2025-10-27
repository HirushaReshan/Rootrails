import 'package:flutter/material.dart';

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
        child: Column(
          children: [
            TextField(
              controller: _card,
              decoration: const InputDecoration(labelText: 'Card number'),
            ),
            TextField(
              controller: _exp,
              decoration: const InputDecoration(labelText: 'MM/YY'),
            ),
            TextField(
              controller: _cvv,
              decoration: const InputDecoration(labelText: 'CVV'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                // Dummy simulate success
                await Future.delayed(const Duration(seconds: 1));
                Navigator.pop(context, true);
              },
              child: const Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
