import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// NOTE: Make sure these models exist in your project structure!
// import 'package:rootrails/models/park.dart';
// import 'package:rootrails/models/business.dart';
import 'package:rootrails/services/auth_service.dart';
import 'package:rootrails/utils/custom_text_field.dart';
import 'package:rootrails/pages/business_user/business_user_home_page.dart';

// --- Custom Colors for Theme Consistency ---
const Color kPrimaryGreen = Color(0xFF4C7D4D); // Dark Green
const Color kCardColor = Colors.white;
const Color kGradientStart = Color(0xFF7CB342); // Light Green for Button
const Color kGradientEnd = Color(0xFF4CAF50); // Dark Green for Button
const Color kBusinessIconColor = Colors.deepOrange; // Accent for Business Page

// --- Custom Clipper for the Rounded Card Shape ---
class TopRoundedClipper extends CustomClipper<Path> {
  final double radius;

  TopRoundedClipper(this.radius);

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius))
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Placeholder classes since your models aren't provided. You MUST replace these
// with your actual model files to run without error.
class Park {
  final String id;
  final String name;
  Park({required this.id, required this.name});
  factory Park.fromFirestore(DocumentSnapshot doc) {
    // Implement your actual deserialization logic here
    return Park(id: doc.id, name: doc['name'] as String? ?? 'Unknown Park');
  }
}

class Business {
  final String uid;
  final String email;
  final String role;
  final String businessName;
  final String businessDescription;
  final double pricePerSafari;
  final double safariDurationHours;
  final String locationInfo;
  final bool isOpen;
  final String businessType;
  final String parkId;
  final double rating;
  final String businessImageUrl;
  final String driverImageUrl;

  Business({
    required this.uid,
    required this.email,
    required this.role,
    required this.businessName,
    required this.businessDescription,
    required this.pricePerSafari,
    required this.safariDurationHours,
    required this.locationInfo,
    required this.isOpen,
    required this.businessType,
    required this.parkId,
    required this.rating,
    required this.businessImageUrl,
    required this.driverImageUrl,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'business_name': businessName,
      'business_description': businessDescription,
      'price_per_safari': pricePerSafari,
      'safari_duration_hours': safariDurationHours,
      'location_info': locationInfo,
      'is_open': isOpen,
      'business_type': businessType,
      'park_id': parkId,
      'rating': rating,
      'business_image_url': businessImageUrl,
      'driver_image_url': driverImageUrl,
    };
  }
}
// End of Placeholder classes

class BusinessUserRegistrationPage extends StatefulWidget {
  const BusinessUserRegistrationPage({super.key});

  @override
  State<BusinessUserRegistrationPage> createState() =>
      _BusinessUserRegistrationPageState();
}

class _BusinessUserRegistrationPageState
    extends State<BusinessUserRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Park> _parksList = [
    // Add a placeholder park for demonstration if Firestore is not connected
    Park(id: 'p1', name: 'Yala National Park'),
    Park(id: 'p2', name: 'Wilpattu National Park'),
  ];
  Park? _selectedPark;
  bool _isParkLoading = false; // Set to false since we use mock data above

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchParks();
  }

  Future<void> _fetchParks() async {
    // Since we're providing the full file, I will wrap the Firestore call in a
    // try/catch but keep the mock list above to ensure the UI builds without errors.
    setState(() {
      _isParkLoading = true;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('parks')
          .get();
      // Ensure the list is populated from Firestore if successful
      _parksList = snapshot.docs.map((doc) => Park.fromFirestore(doc)).toList();
    } catch (e) {
      // In a real app, log error or show snackbar
      print("Error fetching parks: $e");
    } finally {
      setState(() {
        _isParkLoading = false;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPark == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a park.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        final newBusinessProfile = Business(
          uid: user.uid,
          email: _emailController.text.trim(),
          role: 'business_user',
          businessName: _businessNameController.text.trim(),
          businessDescription: _descriptionController.text.trim(),
          pricePerSafari: double.tryParse(_priceController.text) ?? 0.0,
          safariDurationHours: 3.0,
          locationInfo: 'Main Park Entrance',
          isOpen: false,
          businessType: 'park',
          parkId: _selectedPark!.id,
          rating: 0.0,
          businessImageUrl:
              'https://via.placeholder.com/300/FFA000/FFFFFF?text=Safari+Service',
          driverImageUrl:
              'https://via.placeholder.com/150/FF9800/FFFFFF?text=Driver',
        );

        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(user.uid)
            .set(newBusinessProfile.toFirestore());

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': _emailController.text.trim(),
          'role': 'business_user',
          'first_name': _businessNameController.text.trim(),
          'last_name': '',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registration successful! Please update your full profile.',
              ),
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const BusinessUserHomePage(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration Failed: ${e.toString().split(':').last.trim()}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const double headerHeight = 0.35;
    const double overlapOffset = 0.05;

    return Scaffold(
      backgroundColor: kPrimaryGreen,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // --- TOP BACKGROUND CONTAINER ---
            Container(
              height: screenHeight * headerHeight,
              width: double.infinity,
              color: kPrimaryGreen,
            ),

            // --- GREEN HEADER CONTENT ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: kCardColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Icon placeholder
                    const Icon(
                      Icons.directions_bus,
                      size: 80,
                      color: kBusinessIconColor,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Become a Partner',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kCardColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- MAIN REGISTRATION CARD (White Area) ---
            Container(
              margin: EdgeInsets.only(
                top: screenHeight * (headerHeight - overlapOffset),
              ),
              child: ClipPath(
                clipper: TopRoundedClipper(30),
                child: Container(
                  color: kCardColor,
                  constraints: BoxConstraints(
                    minHeight:
                        screenHeight * (1.0 - (headerHeight - overlapOffset)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  width: double.infinity,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 40),

                        Text(
                          'List Your Safari Service',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 30),

                        // Business Name
                        const Text(
                          'Business Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _businessNameController,
                          hintText: 'Business/Driver Name',
                          validator: (v) =>
                              v!.isEmpty ? 'Business name is required' : null,
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        const Text(
                          'Email',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'business@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty || !v.contains('@')
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        const Text(
                          'Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: '********',
                          obscureText: !_isPasswordVisible,
                          validator: (v) => v!.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: kPrimaryGreen,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- Park Dropdown (Wrapped for consistent spacing) ---
                        const Text(
                          'Select Park',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          // The height and padding of this container help simulate the CustomTextField height
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          decoration: BoxDecoration(
                            color:
                                kInputFillColor, // Use the light grey fill color from CustomTextField
                            borderRadius: BorderRadius.circular(
                              CustomTextField.kTextFieldRadius,
                            ),
                          ),
                          child: _isParkLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: CircularProgressIndicator(
                                      color: kPrimaryGreen,
                                    ),
                                  ),
                                )
                              : DropdownButtonFormField<Park>(
                                  value: _selectedPark,
                                  hint: const Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text('Select Your Park'),
                                  ),
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    // Remove all borders to match CustomTextField's visual style
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 15,
                                    ),
                                    fillColor: Colors
                                        .transparent, // Color handled by parent container
                                    filled: true,
                                  ),
                                  items: _parksList.map((Park park) {
                                    return DropdownMenuItem<Park>(
                                      value: park,
                                      child: Text(park.name),
                                    );
                                  }).toList(),
                                  onChanged: (Park? newValue) {
                                    setState(() {
                                      _selectedPark = newValue;
                                    });
                                  },
                                  validator: (value) =>
                                      value == null ? 'Park is required' : null,
                                ),
                        ),
                        const SizedBox(height: 20),
                        // --- End Park Dropdown ---

                        // Price
                        const Text(
                          'Price per Safari',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _priceController,
                          hintText: 'Price per Safari (e.g.,LKR 12,500)',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v!.isEmpty || double.tryParse(v) == null
                              ? 'Enter a valid price'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Description
                        const Text(
                          'Service Description',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _descriptionController,
                          hintText: 'Short Service Description',
                          maxLines: 3,
                          validator: (v) =>
                              v!.isEmpty ? 'Description is required' : null,
                        ),
                        const SizedBox(height: 30),

                        // Register Button (Styled with Gradient)
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [kGradientStart, kGradientEnd],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kGradientEnd.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _register,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Center(
                                      child: Text(
                                        'Register Service',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                        const SizedBox(height: 20),

                        // Login Link
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Already registered? Sign In',
                            style: TextStyle(
                              color: kPrimaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
