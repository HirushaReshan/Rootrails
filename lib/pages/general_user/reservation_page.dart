import 'package:flutter/material.dart';
import 'package:rootrails/models/driver.dart';
import 'package:rootrails/utils/custom_text_field.dart';
import 'dummy_payment_page.dart';

class ReservationPage extends StatefulWidget {
  final Driver driver;
  final String parkName;

  const ReservationPage({super.key, required this.driver, required this.parkName});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  final List<String> _availableTimes = ['8:00 AM', '10:00 AM', '1:00 PM', '3:00 PM'];
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _bookNow() {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot.')),
      );
      return;
    }
    
    // Navigate to the dummy payment page with booking details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DummyPaymentPage(
          driver: widget.driver,
          parkName: widget.parkName,
          bookingDate: _selectedDate,
          bookingTime: _selectedTime!,
          notes: _notesController.text,
        ),
      ),
    );
  }

  Widget _buildTimeContainer(String time) {
    final isSelected = _selectedTime == time;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTime = time;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Reservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking: ${widget.driver.businessName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text('Park: ${widget.parkName}', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 5),
                      Text('Price: \$${widget.driver.pricePerSafari.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Time Selection
              Text('1. Select Available Time Slot', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: _availableTimes.map((time) => _buildTimeContainer(time)).toList(),
              ),
              const SizedBox(height: 30),

              // Date Selection
              Text('2. Select Date', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                  'Selected Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 30),

              // Notes
              Text('3. Add Notes (Optional)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _notesController,
                hintText: 'e.g., specific pickup instructions, number of people...',
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _bookNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: const Text(
            'Proceed to Payment',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}