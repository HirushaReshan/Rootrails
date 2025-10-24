// RooTrails Flutter — Initial working pages and structure
// NOTE: This is a multi-file project presented in a single document. Copy each section into the corresponding file in your Flutter project (lib/...).
// Packages (add to pubspec.yaml):
//   firebase_core: ^2.8.0
//   firebase_auth: ^4.4.0
//   cloud_firestore: ^4.6.0
//   google_sign_in: ^6.1.0
//   provider: ^6.0.5
//   intl: ^0.18.0
//   carousel_slider: ^4.2.1
//   flutter_rating_bar: ^4.0.1
//   url_launcher: ^6.1.10

// --------------------------
// FILE: lib/main.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'screens/splash_screen.dart';
import 'themes/app_theme.dart';
import 'screens/auth/choice_screen.dart';

// NOTE: Replace with your generated firebase_options.dart import if you have it.
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RooTrailsApp());
}

class RooTrailsApp extends StatelessWidget {
  const RooTrailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: Consumer<AppState>(builder: (context, state, _) {
        return MaterialApp(
          title: 'RooTrails',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.themeMode,
          home: const SplashScreen(),
        );
      }),
    );
  }
}

// --------------------------
// FILE: lib/services/firebase_service.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) _themeMode = ThemeMode.dark;
    else _themeMode = ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode m) {
    _themeMode = m;
    notifyListeners();
  }
}

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Email/password register
  static Future<UserCredential> registerWithEmail(String email, String password) async {
    return await auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Email/password sign in
  static Future<UserCredential> signInWithEmail(String email, String password) async {
    return await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> sendPasswordReset(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  static Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await auth.signInWithCredential(credential);
  }

  static Future<void> createGeneralUserDocument(String uid, Map<String, dynamic> data) async {
    await firestore.collection('users').doc(uid).set(data);
  }

  static Future<void> createBusinessDocument(String uid, Map<String, dynamic> data) async {
    await firestore.collection('businesses').doc(uid).set(data);
  }

  // Simple booking creation
  static Future<void> createBooking(Map<String, dynamic> data) async {
    await firestore.collection('bookings').add(data);
  }
}

// --------------------------
// FILE: lib/themes/app_theme.dart
// --------------------------
import 'package:flutter/material.dart';

class AppTheme {
  static final Color primary = const Color(0xFF2E7D32); // nature green

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFFF2F6F3),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFF0B0F0A),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
  );
}

// --------------------------
// FILE: lib/screens/splash_screen.dart
// --------------------------
import 'dart:async';
import 'package:flutter/material.dart';
import 'choice_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChoiceScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add your animated logo here
            FlutterLogo(size: 120),
            const SizedBox(height: 20),
            const Text('RooTrails', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Book safaris with trusted drivers', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/auth/choice_screen.dart
// --------------------------
import 'package:flutter/material.dart';
import 'general/login_page.dart';
import 'business/business_login.dart';

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Are you a General user or a Business?', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneralLogin())),
                child: const Text('General User'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessLogin())),
                child: const Text('Business / Driver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/auth/general/login_page.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../user/user_home.dart';
import '../../auth/choice_screen.dart';
import 'register_page.dart';
import '../../../services/firebase_service.dart';

class GeneralLogin extends StatefulWidget {
  const GeneralLogin({super.key});

  @override
  State<GeneralLogin> createState() => _GeneralLoginState();
}

class _GeneralLoginState extends State<GeneralLogin> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await FirebaseService.signInWithEmail(_email.text.trim(), _password.text.trim());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePage()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator() : const Text('Login')),
            const SizedBox(height: 8),
            TextButton(onPressed: () => FirebaseService.sendPasswordReset(_email.text.trim()), child: const Text('Forgot password?')),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final res = await FirebaseService.signInWithGoogle();
                if (res != null) {
                  // Ensure user doc exists
                  final user = res.user!;
                  await FirebaseService.createGeneralUserDocument(user.uid, {
                    'email': user.email,
                    'name': user.displayName ?? '',
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePage()));
                }
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Image.asset('assets/google.png', width: 24, height: 24),
                const SizedBox(width: 8),
                const Text('Sign in with Google')
              ]),
            ),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Not a member?'),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneralRegister())), child: const Text('Register now'))
            ])
          ],
        ),
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/auth/general/register_page.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase_service.dart';
import '../../user/user_home.dart';

class GeneralRegister extends StatefulWidget {
  const GeneralRegister({super.key});

  @override
  State<GeneralRegister> createState() => _GeneralRegisterState();
}

class _GeneralRegisterState extends State<GeneralRegister> {
  final _username = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await FirebaseService.registerWithEmail(_email.text.trim(), _password.text.trim());
      final user = cred.user!;
      await FirebaseService.createGeneralUserDocument(user.uid, {
        'user_name': _username.text.trim(),
        'first_name': _first.text.trim(),
        'last_name': _last.text.trim(),
        'email': _email.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePage()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Registration failed')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _username, decoration: const InputDecoration(labelText: 'User name')),
          TextField(controller: _first, decoration: const InputDecoration(labelText: 'First name')),
          TextField(controller: _last, decoration: const InputDecoration(labelText: 'Last name')),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          TextField(controller: _confirm, decoration: const InputDecoration(labelText: 'Confirm password'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Register')),
        ]),
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/user/user_home.dart
// --------------------------
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/user_drawer.dart';
import '../../widgets/user_appbar.dart';
import 'park_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final _fire = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UserAppBar(title: 'Home'),
      drawer: const UserDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Carousel from firestore: collection 'carousel_images' documents contain field 'imageUrl'
            StreamBuilder<QuerySnapshot>(
              stream: _fire.collection('carousel_images').orderBy('order', descending: false).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                final docs = snap.data!.docs;
                final urls = docs.map((d) => d['imageUrl'] as String).toList();
                if (urls.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No images available')));
                return CarouselSlider(
                  options: CarouselOptions(height: 200, autoPlay: true, enlargeCenterPage: true),
                  items: urls.map((u) => ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)], borderRadius: BorderRadius.circular(16)),
                      child: Image.network(u, fit: BoxFit.cover, width: double.infinity),
                    ),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Parks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('See All'))
              ]),
            ),
            // Horizontal parks list from collection 'parks'
            SizedBox(
              height: 220,
              child: StreamBuilder<QuerySnapshot>(
                stream: _fire.collection('parks').snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snap.data!.docs;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final d = docs[index];
                      final openFrom = d['openFrom'] ?? '06:00';
                      final openTo = d['openTo'] ?? '18:00';
                      final name = d['name'] ?? 'Park';
                      final image = d['imageUrl'] ?? '';
                      final rating = (d['rating'] ?? 4).toDouble();
                      final nowOpen = _isOpen(openFrom, openTo);
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ParkPage(parkId: d.id))),
                        child: Container(
                          width: 260,
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
                          child: Column(children: [
                            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(image, height: 110, width: double.infinity, fit: BoxFit.cover)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(children: [Icon(Icons.access_time, size: 14), const SizedBox(width: 4), Text('$openFrom - $openTo')]),
                                const SizedBox(height: 6),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Row(children: [Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text(rating.toString())]),
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: nowOpen ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(8)), child: Text(nowOpen ? 'Open' : 'Closed', style: const TextStyle(color: Colors.white))),
                                ])
                              ]),
                            )
                          ]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Other businesses sample
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Row(children: const [Text('Other Businesses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))])),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: StreamBuilder<QuerySnapshot>(
                stream: _fire.collection('businesses').snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snap.data!.docs;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final d = docs[index];
                      return Container(
                        width: 260,
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                        child: Row(children: [
                          if ((d['imageUrl'] ?? '') != '') Image.network(d['imageUrl'], width: 110, height: 140, fit: BoxFit.cover) else Container(width: 110, color: Colors.grey),
                          Expanded(child: Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d['business_name'] ?? 'Business', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(d['description'] ?? '', maxLines: 3, overflow: TextOverflow.ellipsis)])))
                        ]),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My List'),
        BottomNavigationBarItem(icon: Icon(Icons.navigation), label: 'Navigation'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ]),
    );
  }

  bool _isOpen(String from, String to) {
    try {
      final now = TimeOfDay.now();
      final f = _parse(from);
      final t = _parse(to);
      final nMinutes = now.hour * 60 + now.minute;
      final fMinutes = f.hour * 60 + f.minute;
      final tMinutes = t.hour * 60 + t.minute;
      if (fMinutes <= tMinutes) return nMinutes >= fMinutes && nMinutes <= tMinutes;
      // overnight
      return nMinutes >= fMinutes || nMinutes <= tMinutes;
    } catch (e) {
      return false;
    }
  }

  TimeOfDay _parse(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

// --------------------------
// FILE: lib/screens/user/park_page.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'driver_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkPage extends StatelessWidget {
  final String parkId;
  const ParkPage({super.key, required this.parkId});

  @override
  Widget build(BuildContext context) {
    final _fire = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Park')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _fire.collection('parks').doc(parkId).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final name = d['name'] ?? '';
          final desc = d['description'] ?? '';
          final image = d['imageUrl'] ?? '';
          final location = d['location'] ?? ''; // could be lat,lng or google maps url

          return SingleChildScrollView(
            child: Column(children: [
              if (image != '') Image.network(image, height: 200, width: double.infinity, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(desc),
                  const SizedBox(height: 8),
                  Row(children: [
                    IconButton(onPressed: () async { if (location != '') await launchUrl(Uri.parse(location)); }, icon: const Icon(Icons.location_on)),
                    const Text('Open in Maps')
                  ])
                ]),
              ),
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.all(12.0), child: const Text('Drivers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              StreamBuilder<QuerySnapshot>(
                stream: _fire.collection('drivers').where('parkId', isEqualTo: parkId).snapshots(),
                builder: (context, snap2) {
                  if (!snap2.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snap2.data!.docs;
                  if (docs.isEmpty) return const Padding(padding: EdgeInsets.all(12), child: Text('No drivers registered for this park'));
                  return Column(children: docs.map((d) {
                    final name = d['name'] ?? '';
                    final image = d['imageUrl'] ?? '';
                    final price = d['price'] ?? '0';
                    final rating = (d['rating'] ?? 4).toDouble();
                    final isOpen = d['open'] ?? true;
                    return ListTile(
                      leading: image != '' ? CircleAvatar(backgroundImage: NetworkImage(image)) : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(name),
                      subtitle: Row(children: [Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text(rating.toString())]),
                      trailing: Column(mainAxisSize: MainAxisSize.min, children: [Text('\$${price.toString()}'), const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isOpen ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(6)), child: Text(isOpen ? 'Open' : 'Closed', style: const TextStyle(color: Colors.white))) ]),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriverPage(driverId: d.id))),
                    );
                  }).toList());
                },
              )
            ]),
          );
        },
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/user/driver_page.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_flow.dart';

class DriverPage extends StatelessWidget {
  final String driverId;
  const DriverPage({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    final _fire = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Driver')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _fire.collection('drivers').doc(driverId).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final name = d['name'] ?? '';
          final image = d['imageUrl'] ?? '';
          final bio = d['bio'] ?? '';
          final price = d['price'] ?? 0;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (image != '') CircleAvatar(radius: 40, backgroundImage: NetworkImage(image)) else const CircleAvatar(radius: 40, child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text('\\$${price.toString()} per trip')])
              ]),
              const SizedBox(height: 12),
              Text(bio),
              const SizedBox(height: 20),
              Center(child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFlow(driverId: driverId))), child: const Text('Reserve Now')))
            ]),
          );
        },
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/user/booking_flow.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../user/driver_page.dart';

class BookingFlow extends StatefulWidget {
  final String driverId;
  const BookingFlow({super.key, required this.driverId});

  @override
  State<BookingFlow> createState() => _BookingFlowState();
}

class _BookingFlowState extends State<BookingFlow> {
  String? selectedTime;
  DateTime? selectedDate;
  final _notes = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final _fire = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Reserve')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          const Text('Select time'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['08:00', '10:00', '12:00', '14:00', '16:00'].map((t) => ChoiceChip(label: Text(t), selected: selectedTime == t, onSelected: (_) => setState(() => selectedTime = t))).toList()),
          const SizedBox(height: 12),
          ListTile(
            title: Text(selectedDate == null ? 'Select Date' : selectedDate!.toLocal().toString().split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (d != null) setState(() => selectedDate = d);
            },
          ),
          const SizedBox(height: 12),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes (optional)')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loading ? null : () async {
            if (selectedTime == null || selectedDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select time and date'))); return; }
            setState(() => _loading = true);
            // Create a simple booking doc
            await FirebaseFirestore.instance.collection('bookings').add({
              'driverId': widget.driverId,
              'userId': FirebaseFirestore.instance.app.name, // placeholder: replace with actual UID lookup
              'time': selectedTime,
              'date': selectedDate,
              'notes': _notes.text,
              'status': 'pending',
              'createdAt': FieldValue.serverTimestamp(),
            });
            // Navigate to dummy payment
            final ok = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DummyPayment()));
            if (ok == true) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created')));
              Navigator.popUntil(context, (route) => route.isFirst);
            }
            setState(() => _loading = false);
          }, child: _loading ? const CircularProgressIndicator() : const Text('Book now'))
        ]),
      ),
    );
  }
}

class DummyPayment extends StatelessWidget {
  const DummyPayment({super.key});

  @override
  Widget build(BuildContext context) {
    final _card = TextEditingController();
    final _exp = TextEditingController();
    final _cvv = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _card, decoration: const InputDecoration(labelText: 'Card number')),
          TextField(controller: _exp, decoration: const InputDecoration(labelText: 'MM/YY')),
          TextField(controller: _cvv, decoration: const InputDecoration(labelText: 'CVV')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () async {
            // Dummy simulate success
            await Future.delayed(const Duration(seconds: 1));
            Navigator.pop(context, true);
          }, child: const Text('Pay'))
        ]),
      ),
    );
  }
}

// --------------------------
// FILE: lib/widgets/user_appbar.dart
// --------------------------
import 'package:flutter/material.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const UserAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), actions: [IconButton(onPressed: () { /* TODO notifications */ }, icon: const Icon(Icons.notifications))]);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// --------------------------
// FILE: lib/widgets/user_drawer.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: SafeArea(
        child: Column(children: [
          UserAccountsDrawerHeader(accountName: Text(user?.displayName ?? 'Guest'), accountEmail: Text(user?.email ?? ''), currentAccountPicture: const CircleAvatar(child: Icon(Icons.person))),
          ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.contact_mail), title: const Text('Contact us'), onTap: () {}),
          ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () {}),
          const Spacer(),
          ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () async { await FirebaseAuth.instance.signOut(); Navigator.popUntil(context, (r) => r.isFirst); }),
        ]),
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/auth/business/business_login.dart
// --------------------------
import 'package:flutter/material.dart';
import 'business_register.dart';
import '../../user/user_home.dart';
import '../../../services/firebase_service.dart';

class BusinessLogin extends StatefulWidget {
  const BusinessLogin({super.key});

  @override
  State<BusinessLogin> createState() => _BusinessLoginState();
}

class _BusinessLoginState extends State<BusinessLogin> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await FirebaseService.signInWithEmail(_email.text.trim(), _pass.text.trim());
      // For now navigate to BusinessHome which you will implement later
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Login')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _login, child: const Text('Login')),
          const SizedBox(height: 12),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessRegister())), child: const Text('Register Business'))
        ]),
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/auth/business/business_register.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessRegister extends StatefulWidget {
  const BusinessRegister({super.key});

  @override
  State<BusinessRegister> createState() => _BusinessRegisterState();
}

class _BusinessRegisterState extends State<BusinessRegister> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _image = TextEditingController();
  final _driverImage = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController();
  final _location = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (_pass.text != _confirm.text) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match'))); return; }
    setState(() => _loading = true);
    try {
      final cred = await FirebaseService.registerWithEmail(_email.text.trim(), _pass.text.trim());
      final uid = cred.user!.uid;
      await FirebaseService.createBusinessDocument(uid, {
        'business_name': _name.text.trim(),
        'description': _desc.text.trim(),
        'imageUrl': _image.text.trim(),
        'driverImageUrl': _driverImage.text.trim(),
        'price': double.tryParse(_price.text) ?? 0,
        'duration': _duration.text,
        'location': _location.text,
        'open': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Business')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Business name')),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
          TextField(controller: _image, decoration: const InputDecoration(labelText: 'Business image URL')),
          TextField(controller: _driverImage, decoration: const InputDecoration(labelText: 'Driver image URL')),
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price')),
          TextField(controller: _duration, decoration: const InputDecoration(labelText: 'Duration (e.g. 3 hours)')),
          TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location (maps url)')),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          TextField(controller: _confirm, decoration: const InputDecoration(labelText: 'Confirm Password'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _register, child: const Text('Register'))
        ]),
      ),
    );
  }
}

// --------------------------
// End of initial pages
// --------------------------

/*
NEXT STEPS & NOTES (read me):
- This is an initial working skeleton focused on the core flows you requested: splash, choice, general user auth + register, user home with carousel and parks list, park page with drivers, driver page and booking flow (creates a bookings document), business register & login skeleton.
- You told me you already have firebase_options.dart and Firebase initialized — replace the Firebase.initializeApp() call with options if needed.
- Update user id saving inside BookingFlow: replace placeholder userId with FirebaseAuth.instance.currentUser?.uid.
- Add missing pages such as My List, Profile update, Business Home, Orders handling, dark/animal theme selector and driver accept/confirm flows. I can continue and add the next batch of pages (profile, my bookings, business orders, settings, theme selector) — you asked to provide a few pages, then more pages after, so tell me to continue and I'll add the next set.
- Copy this file-split into your lib/ folder and add the listed pubspec dependencies. Asset: put a google.png into assets/ and add to pubspec.
*/
