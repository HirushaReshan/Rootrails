import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_button.dart';

class BusinessDetailPage extends StatelessWidget {
  final String businessId;
  const BusinessDetailPage({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance.collection('Business_Users').doc(businessId);

    return Scaffold(
      appBar: AppBar(title: const Text('Business Details')),
      body: FutureBuilder(
        future: docRef.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['businessName'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(data['businessDescription'] ?? ''),
                const SizedBox(height: 12),
                if (data['imageUrl'] != null)
                  Image.network(data['imageUrl'], height: 150, fit: BoxFit.cover),
                const SizedBox(height: 24),
                MyButton(
                  onTap: () {
                    Navigator.pushNamed(context, '/booking', arguments: businessId);
                  },
                  text: 'Book Now',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
