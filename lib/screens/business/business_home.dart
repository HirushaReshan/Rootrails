import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/bottom_nav.dart';
import '../navigation/navigation_page.dart';
import 'business_orders.dart';
import 'business_profile.dart';
import 'driver_management.dart';
import 'business_profile_tab.dart';

class BusinessHomePage extends StatefulWidget {
  const BusinessHomePage({super.key});

  @override
  State<BusinessHomePage> createState() => _BusinessHomePageState();
}

class _BusinessHomePageState extends State<BusinessHomePage> {
  int _currentIndex = 0;
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BusinessHomeContent(fire: _fire, auth: _auth),
      const BusinessOrders(),
      const NavigationPage(),
      const BusinessProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Business')),
      body: pages[_currentIndex],
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class BusinessHomeContent extends StatelessWidget {
  final FirebaseFirestore fire;
  final FirebaseAuth auth;
  const BusinessHomeContent({
    super.key,
    required this.fire,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    final uid = auth.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Not signed in'));

    return StreamBuilder<DocumentSnapshot>(
      stream: fire.collection('businesses').doc(uid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final d = snap.data!;
        final name = d['business_name'] ?? 'Business';
        final desc = d['description'] ?? '';
        final open = d['open'] ?? false;
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(desc),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Open status: '),
                  Switch(
                    value: open,
                    onChanged: (v) async {
                      await fire.collection('businesses').doc(uid).update({
                        'open': v,
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Business'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BusinessProfile(),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.people),
                    label: const Text('Manage Drivers'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DriverManagement(),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text('Assign Park'),
                    onPressed: () => _showAssignParkDialog(context, fire, uid),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View Orders'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BusinessOrders()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Quick actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // extra UI could go here
            ],
          ),
        );
      },
    );
  }

  void _showAssignParkDialog(
    BuildContext context,
    FirebaseFirestore fire,
    String businessId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Park'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: fire.collection('parks').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData)
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                final docs = snap.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final p = docs[index];
                    return ListTile(
                      title: Text(p['name'] ?? 'Park'),
                      subtitle: Text(p['description'] ?? ''),
                      onTap: () async {
                        await fire.collection('parks').doc(p.id).update({
                          'businesses': FieldValue.arrayUnion([businessId]),
                        });
                        await fire
                            .collection('businesses')
                            .doc(businessId)
                            .update({'parkId': p.id});
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Assigned to park')),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
