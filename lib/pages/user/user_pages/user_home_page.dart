import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/drawer/user_drawer.dart';
import 'package:rootrails/read%20data/get_user_name.dart';

class UserHomePage extends StatefulWidget {
  UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<UserHomePage> {
    final user = FirebaseAuth.instance.currentUser!;

    //Document IDs
    List<String> docsIDs = [];

    //get Document IDs
    Future getDocId() async {
      docsIDs.clear();
      await FirebaseFirestore.instance.collection('Business_Users').get().then(
        (snapshot) => snapshot.docs.forEach(
          (document) {
            print(document.reference);
            docsIDs.add(document.reference.id);
          }
        )
      );
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade400,
        title: Text(
              'Logged in as : ' + user.email!,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
              ),
            ),
      ),
      drawer: UserDrawer(),


      body: Center(
        child: Column(
          children: [

            Text('Business Page'),
            
            Expanded(
              child: FutureBuilder(
                future: getDocId(),
                builder: (context, snapshot) {
                  return ListView.builder(
                itemCount: docsIDs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: GetUserName(documentId: docsIDs[index]),
                  );
                },
              );
                },
              )
            )
          ],
        ),
      ),
    );
  }
}