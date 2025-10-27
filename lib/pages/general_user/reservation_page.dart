import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rootrails/models/driver.dart';
import 'package:rootrails/pages/general_user/dummy_payment_page.dart';
import 'package:rootrails/utils/custom_text_field.dart';

class ReservationPage extends StatefulWidget {
  final Driver driver;
  final String parkName;
  const ReservationPage({
    super.key,
    required this.driver,
    required this.parkName,
  });

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date and time to proceed.'),
        ),
      );
      return;
    }

    // Format time for storage
    final String formattedTime = _selectedTime!.format(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DummyPaymentPage(
          driver: widget.driver,
          parkName: widget.parkName,
          bookingDate: _selectedDate!,
          bookingTime: formattedTime,
          notes: _notesController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.driver.pricePerSafari;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Reservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking with: ${widget.driver.businessName}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                'At: ${widget.parkName}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
              const Divider(height: 30),

              // Date Selection
              Text(
                '1. Select Date',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              _buildDateTimePicker(
                context,
                icon: Icons.date_range,
                title: _selectedDate == null
                    ? 'Choose Date'
                    : DateFormat('EEE, MMM d, yyyy').format(_selectedDate!),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),

              // Time Selection
              Text(
                '2. Select Time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              _buildDateTimePicker(
                context,
                icon: Icons.access_time,
                title: _selectedTime == null
                    ? 'Choose Time'
                    : _selectedTime!.format(context),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 20),

              // Notes
              Text(
                '3. Add Notes (Optional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _notesController,
                hintText: 'e.g., Number of people, special requests...',
                maxLines: 3,
              ),
              const SizedBox(height: 40),

              // Price Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Price:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _proceedToPayment,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'Proceed to Payment',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 10),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            const Icon(Icons.edit, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
