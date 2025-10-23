import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_textfield.dart';
import 'package:rootrails/components/cards/my_button.dart';

class AddBusinessPage extends StatefulWidget {
  final String ownerId;
  const AddBusinessPage({super.key, required this.ownerId});

  @override
  State<AddBusinessPage> createState() => _AddBusinessPageState();
}

class _AddBusinessPageState extends State<AddBusinessPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  bool loading = false;

  void addBusiness() async {
    if (nameController.text.isEmpty || locationController.text.isEmpty) return;

    setState(() => loading = true);

    await FirebaseFirestore.instance.collection('Businesses').add({
      'ownerId': widget.ownerId,
      'businessName': nameController.text.trim(),
      'location': locationController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Business')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MyTextfield(controller: nameController, hintText: 'Business Name'),
            const SizedBox(height: 16),
            MyTextfield(controller: locationController, hintText: 'Location'),
            const SizedBox(height: 32),
            MyButton(
              text: loading ? 'Adding...' : 'Add Business',
              onTap: addBusiness,
            ),
          ],
        ),
      ),
    );
  }
}
