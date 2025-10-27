import 'package:flutter/material.dart';
import 'package:rootrails/pages/general_user/general_user_login_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  // Widget for a large, tappable role card
  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Are you planning a trip or offering one?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildRoleCard(
                context: context,
                title: 'General User',
                subtitle: 'Book exciting safaris and adventures!',
                icon: Icons.person_search,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GeneralUserLoginPage(),
                    ),
                  );
                },
              ),
              _buildRoleCard(
                context: context,
                title: 'Business User (Driver)',
                subtitle: 'Register your safari business and accept bookings.',
                icon: Icons.drive_eta,
                onTap: () {
                  // TODO: Navigate to Business User Login Page
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const BusinessUserLoginPage()),
                  // );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Business Login page coming soon!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
