import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_card.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Parks')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Parks').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final parks = snapshot.data!.docs;
          return ListView.builder(
            itemCount: parks.length,
            itemBuilder: (context, index) {
              final park = parks[index];
              return MyCard(
                title: park['name'] ?? 'Unnamed Park',
                subtitle: park['location'] ?? '',
                onTap: () {
                  Navigator.pushNamed(context, '/park_detail', arguments: park.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
