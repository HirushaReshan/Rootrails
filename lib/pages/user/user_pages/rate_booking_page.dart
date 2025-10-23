import 'package:flutter/material.dart';
import 'package:rootrails/services/firestore_service.dart';

class RateBookingPage extends StatefulWidget {
  final String bookingId;
  const RateBookingPage({super.key, required this.bookingId});

  @override
  State<RateBookingPage> createState() => _RateBookingPageState();
}

class _RateBookingPageState extends State<RateBookingPage> {
  final fs = FirestoreService();
  final commentCtrl = TextEditingController();
  int stars = 0;
  bool loading = false;

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  Future<void> submitRating() async {
    if (stars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() => loading = true);
    await fs.rateBooking(widget.bookingId, stars, commentCtrl.text.trim());
    if (mounted) {
      setState(() => loading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Select stars:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return IconButton(
                  icon: Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                  ),
                  onPressed: () => setState(() => stars = i + 1),
                );
              }),
            ),
            TextField(
              controller: commentCtrl,
              decoration: const InputDecoration(hintText: 'Add comment (optional)'),
            ),
            const SizedBox(height: 16),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submitRating,
                    child: const Text('Submit'),
                  ),
          ],
        ),
      ),
    );
  }
}
