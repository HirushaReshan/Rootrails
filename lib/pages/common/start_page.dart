import 'package:flutter/material.dart';
import 'package:rootrails/pages/common/role_selection_page.dart';

const Color kPrimaryGreen = Color(0xFF4C7D4D);
const String kLeopardImagePath = 'lib/images/Leopard_start.png';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final greenWidth = screenWidth * 0.6;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 3. Paw Prints Background (subtle texture) ---
          Positioned(
            left: screenWidth * 0.2,
            top: 100,
            child: Opacity(
              opacity: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '🐾',
                    style: TextStyle(fontSize: 36, color: Colors.amber),
                  ),
                  SizedBox(height: 50),
                  Text('🐾', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 50),
                  Text('🐾 🐾 🐾 🐾', style: TextStyle(fontSize: 40)),
                ],
              ),
            ),
          ),

          //whitebox top big
          Positioned(
            top: 0,
            left: 0,
            width: screenWidth,
            height: screenHeight,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(),
              child: Container(color: Colors.white),
            ),
          ),

          //green top
          Positioned(
            top: 50,
            left: 50,
            width: screenWidth,
            height: screenHeight * 0.7,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                bottomLeft: Radius.circular(40),
              ),
              child: Container(color: kPrimaryGreen),
            ),
          ),

          //green bottom
          Positioned(
            bottom: 0,
            left: 120,
            width: screenWidth,
            height: screenHeight * 0.2,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
              ),
              child: Container(color: kPrimaryGreen),
            ),
          ),

          // --- 2. Leopard Image on the right ---
          Positioned(
            right: 0,
            bottom: 0,
            width: screenWidth, // full width
            height: screenHeight * 0.7, // 60% of screen height
            child: Image.asset(
              kLeopardImagePath,
              fit: BoxFit.contain, // makes sure it’s not cut off
              alignment: Alignment.bottomRight, // keep it aligned bottom-right
            ),
          ),

          // --- 4. Foreground Text and Button ---
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Stack(
                children: [
                  // “Welcome to”
                  Positioned(
                    top: 100, // adjust freely
                    left: 150,
                    child: const Text(
                      'Welcome\nto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                  ),

                  // Vertical “ROO TRAILS”
                  Positioned(
                    top: 250,
                    left: 80,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Text(
                        'ROO TRAILS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 46,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 10,
                        ),
                      ),
                    ),
                  ),

                  // “Get Started” Button
                  Positioned(
                    bottom: 183,
                    left: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoleSelectionPage(),
                          ),
                        );
                      },
                      label: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.directions_bus_filled, size: 22),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(255, 1, 153, 9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
