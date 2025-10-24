import 'package:flutter/material.dart';
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