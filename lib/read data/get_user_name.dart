import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetUserName extends StatelessWidget {
  final String documentId;

  const GetUserName({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    final CollectionReference parks =
        FirebaseFirestore.instance.collection('Parks');

    return FutureBuilder<DocumentSnapshot>(
      future: parks.doc(documentId).get(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            // let parent decide width; give a reasonable height for placeholder
            height: 220,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Error or no data
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data() == null) {
          return Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(minHeight: 140),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('Failed to load park')),
          );
        }

        final Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;

        // Use LayoutBuilder to adapt to whatever width parent gives
        return LayoutBuilder(builder: (context, constraints) {
          // If parent didn't give a finite width, fall back to a reasonable width
          final effectiveWidth =
              constraints.maxWidth.isFinite ? constraints.maxWidth : 260.0;

          return Container(
            width: effectiveWidth,
            // you can make height flexible; using fixed height is OK for card-like UI
            height: 300,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 190, 190, 190),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              // distribute space so the button stays at bottom without overflow
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Park title
                Text(
                  'Park: ${data['name'] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Info row with two columns that expand to share available width
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['condition'] ?? '-'}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text('${data['rating'] ?? '-'} / 5'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Time: --'),
                            SizedBox(height: 6),
                            Text('Location: --'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // CTA button that fills the card width
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: handle reservation
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // minimumSize could be set here if you want guaranteed width/height
                    ),
                    child: const Text(
                      'Reserve Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
