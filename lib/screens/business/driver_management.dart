import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'driver_form.dart';

class DriverManagement extends StatelessWidget {
  const DriverManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return Scaffold(body: const Center(child: Text('Not signed in')));
    final stream = FirebaseFirestore.instance
        .collection('drivers')
        .where('businessId', isEqualTo: uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Drivers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DriverForm()),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No drivers yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading:
                      (d['imageUrl'] != null &&
                          (d['imageUrl'] as String).isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(d['imageUrl']),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(d['name'] ?? 'Driver'),
                  subtitle: Text(
                    '\$${d['price'] ?? '0'} • ${d['rating'] ?? '4.0'} ★',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DriverForm(driverId: d.id),
                          ),
                        );
                      } else if (v == 'delete') {
                        await FirebaseFirestore.instance
                            .collection('drivers')
                            .doc(d.id)
                            .delete();
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
