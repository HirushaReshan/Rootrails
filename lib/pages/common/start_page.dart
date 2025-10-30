import 'package:flutter/material.dart';
import 'package:rootrails/pages/common/role_selection_page.dart';

// --- Global Constants (Moved to top-level for better access) ---
// Define custom colors for easy changes later
const Color kPrimaryGreen = Color(0xFF4C7D4D);
const Color kSecondaryGreen = Color(0xFF7A9E7A);
const Color kTextColor = Colors.white;

// Define custom asset paths
const String kLeopardImagePath = 'assets/leopard.png';
const IconData kNavigationIcon = Icons.directions_car_filled;

// ====================================================================
// --- CORRECTED: CustomPainter Class (Must be Top-Level) ---
// ====================================================================
class CurvedBackgroundPainter extends CustomPainter {
  final Color color;

  // Constructor now correctly defines the 'color' field
  CurvedBackgroundPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Create a path that covers the desired area with a curved top-left corner
    final path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..arcToPoint(
        const Offset(0, 100), // Starting point of the arc (top-left corner)
        radius: const Radius.circular(50), // Radius of the curve
        clockwise: false,
      )
      ..close();

    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// ====================================================================

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kPrimaryGreen,
      body: Stack(
        children: [
          // --- Background Leopard Image ---
          Positioned(
            right: -100,
            bottom: 0,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                kLeopardImagePath,
                height: screenHeight * 0.9,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
          ),

          // --- Curved Container Shape (Green Overlay) ---
          Positioned.fill(
            child: CustomPaint(
              // Now it correctly calls the top-level class
              painter: CurvedBackgroundPainter(
                kSecondaryGreen.withOpacity(0.9),
              ),
            ),
          ),

          // --- Foreground UI Elements (Text and Button) ---
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 80.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 'Welcome to' text
                    const Text(
                      'Welcome\nto',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: kTextColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 'ROO TRAILS' vertical text
                    Row(
                      children: [
                        RotatedBox(
                          quarterTurns: -1,
                          child: Text(
                            'ROO TRAILS',
                            style: TextStyle(
                              fontSize: 55,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              color: kTextColor.withOpacity(0.8),
                              shadows: const [
                                Shadow(blurRadius: 10.0, color: Colors.black38),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(), // Pushes the button to the bottom
                    // 'Get Started' Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RoleSelectionPage(),
                              ),
                            );
                          },
                          icon: const Icon(kNavigationIcon, size: 24),
                          label: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: kSecondaryGreen,
                            backgroundColor: kTextColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
