import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetUserName extends StatelessWidget {
  final String documentId;

  const GetUserName({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    //get the collection
    CollectionReference business = FirebaseFirestore.instance.collection(
      'Business_Users',
    );

    return FutureBuilder<DocumentSnapshot>(
      future: business.doc(documentId).get(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
            return Text('Business Name: ${data['Business name']}');
        }
        return Text('Loading..');
      }),
    );
  }
}
