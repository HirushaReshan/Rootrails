import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  void _launchEmail() async {
    const emailUrl =
        'mailto:support@safari-booker.com?subject=App%20Support%20Request';
    if (await canLaunchUrlString(emailUrl)) {
      await launchUrlString(emailUrl);
    }
  }

  void _launchPhone() async {
    const phoneUrl = 'tel:+254700000000';
    if (await canLaunchUrlString(phoneUrl)) {
      await launchUrlString(phoneUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'We are here to help!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.redAccent),
                      title: const Text('Email Support'),
                      subtitle: const Text('support@safari-booker.com'),
                      trailing: const Icon(Icons.send),
                      onTap: _launchEmail,
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: const Text('Call Us'),
                      subtitle: const Text('+254 700 000 000'),
                      trailing: const Icon(Icons.call),
                      onTap: _launchPhone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'For urgent driver support, please call our 24/7 line. For general inquiries, email us.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
