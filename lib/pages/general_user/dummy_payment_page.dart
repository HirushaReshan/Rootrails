import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/driver.dart';
import 'package:rootrails/models/booking.dart';
import 'package:rootrails/services/booking_service.dart';
import 'package:rootrails/pages/general_user/general_user_home_page.dart';

class DummyPaymentPage extends StatefulWidget {
  final Driver driver;
  final String parkName;
  final DateTime bookingDate;
  final String bookingTime;
  final String notes;

  const DummyPaymentPage({
    super.key,
    required this.driver,
    required this.parkName,
    required this.bookingDate,
    required this.bookingTime,
    required this.notes,
  });

  @override
  State<DummyPaymentPage> createState() => _DummyPaymentPageState();
}

class _DummyPaymentPageState extends State<DummyPaymentPage> {
  bool _isProcessing = false;

  // Dummy payment fields
  final TextEditingController _cardNumberController = TextEditingController(
    text: '1234 5678 9012 3456',
  );
  final TextEditingController _expiryController = TextEditingController(
    text: '12/26',
  );
  final TextEditingController _cvvController = TextEditingController(
    text: '123',
  );

  Future<void> _completeBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackbar(
        'Authentication error. Please log in again.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Fetch the user's full name from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userFullName = userDoc.data()?['full_name'] ?? user.email;

      // 2. Create the Booking object
      final newBooking = Booking(
        id: '', // Firestore will assign this
        userId: user.uid,
        driverId: widget.driver.uid,
        driverName: widget.driver.businessName,
        parkName: widget.parkName,
        bookingDate: widget.bookingDate,
        bookingTime: widget.bookingTime,
        totalAmount: widget.driver.pricePerSafari,
        notes: widget.notes,
        status: 'pending', // Driver needs to confirm
        userFullName: userFullName,
      );

      // 3. Save to Firestore via BookingService
      await BookingService().createBooking(newBooking);

      if (mounted) {
        _showSnackbar(
          'Payment simulated. Booking sent for driver confirmation!',
          isError: false,
        );
        // Navigate back to the Home page (My List will show the pending booking)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const GeneralUserHomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Booking Failed: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dummy Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            _buildSummaryRow('Driver:', widget.driver.businessName),
            _buildSummaryRow(
              'Date:',
              '${widget.bookingDate.month}/${widget.bookingDate.day}/${widget.bookingDate.year}',
            ),
            _buildSummaryRow('Time:', widget.bookingTime),
            _buildSummaryRow(
              'Price:',
              '\$${widget.driver.pricePerSafari.toStringAsFixed(2)}',
            ),
            const Divider(),

            const SizedBox(height: 30),
            Text(
              'Dummy Payment Form',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 15),

            // Card Number
            TextField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            // Expiry and CVV
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    decoration: const InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            if (_isProcessing) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _completeBooking,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            _isProcessing
                ? 'Processing...'
                : 'Pay \$${widget.driver.pricePerSafari.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
