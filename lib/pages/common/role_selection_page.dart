import 'package:flutter/material.dart';
import 'package:rootrails/pages/general_user/general_user_login_page.dart';
import 'package:rootrails/pages/business_user/business_user_login_page.dart';

const Color kPrimaryGreen = Color(0xFF4C7D4D);
const Color kAccentColor = Color(0xFF8BC34A);

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Remove AppBar and use a flexible body for the header style
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //Branded Header Section (Mimicking a login banner)
            _buildBrandedHeader(context),

            // Role Selection Content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 40.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Choose Your Role',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Are you looking for a safari, or offering a service?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // General User Button (Customer)
                  _buildRoleButton(
                    context,
                    icon: Icons.map_outlined,
                    title: 'Book a Safari (Customer)',
                    subtitle: 'Find drivers and reserve your spot.',
                    color: kPrimaryGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GeneralUserLoginPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Business User Button (Driver)
                  _buildRoleButton(
                    context,
                    icon: Icons.directions_bus_outlined,
                    title: 'Offer Safari Service (Driver)',
                    subtitle: 'Manage your listings and orders.',
                    color: kAccentColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BusinessUserLoginPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for the styled header section
  Widget _buildBrandedHeader(BuildContext context) {
    // We use a safe area to ensure the content starts below the notch/status bar
    return SafeArea(
      child: Container(
        height: 200, // Fixed height for the header banner
        width: double.infinity,
        decoration: BoxDecoration(
          color: kPrimaryGreen, // Branded background color
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50), // Rounded bottom corner style
            bottomRight: Radius.circular(50),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.terrain,//logo
                size: 60,
                color: Colors.white,
              ),
              SizedBox(height: 8),
              Text(
                'ROOTRAILS', //AppName
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for the styled buttons
  Widget _buildRoleButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 8, // Higher elevation for a floating, form-like effect
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color.withOpacity(0.05),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: color, // Use the passed color
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
