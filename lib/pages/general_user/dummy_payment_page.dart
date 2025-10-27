import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rootrails/models/booking.dart';
import 'package:rootrails/models/driver.dart';
import 'package:rootrails/services/booking_service.dart';
import 'package:rootrails/utils/custom_text_field.dart';
import 'general_user_home_page.dart';

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
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  bool _isProcessing = false;

  Future<void> _processPaymentAndBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Simulate Payment Processing delay
      await Future.delayed(const Duration(seconds: 2));

      // 2. Create Booking object
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final newBooking = Booking(
        id: '', // Will be assigned by Firestore
        userId: userId,
        driverId: widget.driver.uid,
        driverName: widget.driver.businessName,
        parkName: widget.parkName,
        bookingDate: widget.bookingDate,
        bookingTime: widget.bookingTime,
        totalAmount: widget.driver.pricePerSafari,
        notes: widget.notes,
        status: 'pending', // Initial status
      );

      // 3. Update Firebase with the new booking
      await _bookingService.createBooking(newBooking);

      // 4. Success message and navigation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment successful! Booking created (Pending confirmation).',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to the General User Home Page and clear history
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const GeneralUserHomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment or Booking Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount: \$${widget.driver.pricePerSafari.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                'for ${widget.driver.businessName} on ${widget.bookingTime}, ${widget.bookingDate.day}/${widget.bookingDate.month}',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),

              // Card Holder Name
              CustomTextField(
                controller: _cardNameController,
                hintText: 'Card Holder Name',
                validator: (v) => v!.isEmpty ? 'Enter card name' : null,
              ),
              const SizedBox(height: 15),

              // Card Number
              CustomTextField(
                controller: _cardNumberController,
                hintText: 'Card Number',
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v!.length != 16 ? 'Enter a valid 16-digit number' : null,
              ),
              const SizedBox(height: 15),

              // Expiry Date and CVV
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _expiryController,
                      hintText: 'MM/YY',
                      keyboardType: TextInputType.datetime,
                      validator: (v) => v!.length != 5 ? 'Invalid date' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomTextField(
                      controller: _cvvController,
                      hintText: 'CVV',
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.length != 3 ? 'Invalid CVV' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Pay Button
              _isProcessing
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _processPaymentAndBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Pay \$${widget.driver.pricePerSafari.toStringAsFixed(2)} and Book',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
