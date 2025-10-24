import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_flow.dart';

class DriverPage extends StatelessWidget {
  final String driverId;
  const DriverPage({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    final _fire = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Driver')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _fire.collection('drivers').doc(driverId).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final name = d['name'] ?? '';
          final image = d['imageUrl'] ?? '';
          final bio = d['bio'] ?? '';
          final price = d['price'] ?? 0;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (image != '') CircleAvatar(radius: 40, backgroundImage: NetworkImage(image)) else const CircleAvatar(radius: 40, child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text('\\$${price.toString()} per trip')])
              ]),
              const SizedBox(height: 12),
              Text(bio),
              const SizedBox(height: 20),
              Center(child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFlow(driverId: driverId))), child: const Text('Reserve Now')))
            ]),
          );
        },
      ),
    );
  }
}
