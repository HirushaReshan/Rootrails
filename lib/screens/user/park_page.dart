import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'driver_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkPage extends StatelessWidget {
  final String parkId;
  const ParkPage({super.key, required this.parkId});

  @override
  Widget build(BuildContext context) {
    final _fire = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Park')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _fire.collection('parks').doc(parkId).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final name = d['name'] ?? '';
          final desc = d['description'] ?? '';
          final image = d['imageUrl'] ?? '';
          final location = d['location'] ?? ''; // could be lat,lng or google maps url

          return SingleChildScrollView(
            child: Column(children: [
              if (image != '') Image.network(image, height: 200, width: double.infinity, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(desc),
                  const SizedBox(height: 8),
                  Row(children: [
                    IconButton(onPressed: () async { if (location != '') await launchUrl(Uri.parse(location)); }, icon: const Icon(Icons.location_on)),
                    const Text('Open in Maps')
                  ])
                ]),
              ),
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.all(12.0), child: const Text('Drivers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              StreamBuilder<QuerySnapshot>(
                stream: _fire.collection('drivers').where('parkId', isEqualTo: parkId).snapshots(),
                builder: (context, snap2) {
                  if (!snap2.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snap2.data!.docs;
                  if (docs.isEmpty) return const Padding(padding: EdgeInsets.all(12), child: Text('No drivers registered for this park'));
                  return Column(children: docs.map((d) {
                    final name = d['name'] ?? '';
                    final image = d['imageUrl'] ?? '';
                    final price = d['price'] ?? '0';
                    final rating = (d['rating'] ?? 4).toDouble();
                    final isOpen = d['open'] ?? true;
                    return ListTile(
                      leading: image != '' ? CircleAvatar(backgroundImage: NetworkImage(image)) : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(name),
                      subtitle: Row(children: [Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text(rating.toString())]),
                      trailing: Column(mainAxisSize: MainAxisSize.min, children: [Text('\$${price.toString()}'), const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isOpen ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(6)), child: Text(isOpen ? 'Open' : 'Closed', style: const TextStyle(color: Colors.white))) ]),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriverPage(driverId: d.id))),
                    );
                  }).toList());
                },
              )
            ]),
          );
        },
      ),
    );
  }
}
