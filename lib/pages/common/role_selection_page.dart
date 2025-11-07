import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rootrails/pages/business_user/business_user_login_page.dart';
import 'package:rootrails/pages/general_user/general_user_login_page.dart';

// Colors
const Color kPrimaryGreen = Color(0xFF5BA84B);
const Color kDarkGreen = Color(0xFF1F4A27);
const String kForestBackground = 'lib/images/forest_bg.png';
const String kAnimalsSilhouette = 'lib/images/animals.png';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // 🟢 Control forest image upward stretch here (0.0 to 0.3 is good)

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 🌿 Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryGreen, kDarkGreen],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🌳 Forest image background (stretchable upward)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              kForestBackground,
              fit: BoxFit.cover,
              height: screenHeight * 0.7,
            ),
          ),

          // 🐾 Animals silhouette overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              kAnimalsSilhouette,
              fit: BoxFit.fitWidth,
              height: screenHeight * 0.3,
            ),
          ),

          // 🟩 Gradient curved top section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopCurvedClipper(),
              child: Container(
                height: screenHeight * 0.7,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 82, 139, 75),
                      Color.fromARGB(255, 25, 53, 21),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // 🌟 Foreground content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 30,
                right: 30
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30,),
                  // 🦁 Title
                  Text(
                    "Explore the Wild with",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    "RooTrails",
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFAB12F),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "Choose how you want to begin your adventure",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // 🟫 Two selection cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRoleCard(
                        context,
                        title: "Book a Safari",
                        description: "Embark on thrilling wildlife tours",
                        highlight: "Plan your journey now",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const GeneralUserLoginPage(),
                            ),
                          );
                        },
                      ),
                      _buildRoleCard(
                        context,
                        title: "Provide a Service",
                        description: "Partner with RooTrails and offer rides",
                        highlight: "Join our Business",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BusinessUserLoginPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🧭 Card builder
  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required String highlight,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(2, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 5),
            Text(
              highlight,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFFFAB12F),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 91, 219, 80),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                "Continue",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// cureved
class TopCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.85);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.85,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
