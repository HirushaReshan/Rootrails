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



//[2]


// RooTrails Flutter — Next batch of pages
// Add these files to lib/... and wire imports as shown. This continues from the initial batch.

// PACKAGES needed (ensure in pubspec.yaml):
// provider, firebase_auth, cloud_firestore, intl

// --------------------------
// FILE: lib/screens/user/profile_page.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _loading = true;
  Map<String, dynamic> _data = {};

  final _username = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _fire.collection('users').doc(uid).get();
    _data = doc.data() ?? {};
    _username.text = _data['user_name'] ?? '';
    _first.text = _data['first_name'] ?? '';
    _last.text = _data['last_name'] ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _fire.collection('users').doc(uid).update({
      'user_name': _username.text.trim(),
      'first_name': _first.text.trim(),
      'last_name': _last.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          CircleAvatar(radius: 44, child: Text((_data['user_name'] ?? 'U').toString().isEmpty ? 'U' : (_data['user_name'][0] ?? 'U'))),
          const SizedBox(height: 12),
          TextField(controller: _username, decoration: const InputDecoration(labelText: 'User name')),
          TextField(controller: _first, decoration: const InputDecoration(labelText: 'First name')),
          TextField(controller: _last, decoration: const InputDecoration(labelText: 'Last name')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ]),
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/user/my_bookings.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Scaffold(body: const Center(child: Text('Not signed in')));
    final stream = FirebaseFirestore.instance.collection('bookings').where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No bookings yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final status = d['status'] ?? 'pending';
              final date = d['date'] is Timestamp ? (d['date'] as Timestamp).toDate() : (d['date'] ?? null);
              final dateStr = date != null ? DateFormat.yMMMd().format(date) : 'N/A';
              final time = d['time'] ?? '';
              final driverId = d['driverId'] ?? '';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text('Driver: ${d['driverName'] ?? driverId}'),
                  subtitle: Text('$dateStr • $time\nStatus: $status'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(onSelected: (v) async {
                    if (v == 'cancel') {
                      await FirebaseFirestore.instance.collection('bookings').doc(d.id).update({'status': 'canceled'});
                    }
                  }, itemBuilder: (_) => [const PopupMenuItem(value: 'cancel', child: Text('Cancel'))]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/settings/settings_page.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../themes/custom_themes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        SwitchListTile(
          title: const Text('Dark mode'),
          value: appState.themeMode == ThemeMode.dark,
          onChanged: (v) => appState.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
        ),
        ListTile(
          title: const Text('Animal theme'),
          subtitle: const Text('Apply nature/animal color accents'),
          trailing: ElevatedButton(onPressed: () => appState.setThemeMode(ThemeMode.system), child: const Text('Apply')),
        ),
        ListTile(title: const Text('Contact us'), subtitle: const Text('support@rootrails.app'), onTap: () {}),
        ListTile(title: const Text('Logout'), onTap: () async { await FirebaseService.auth.signOut(); Navigator.popUntil(context, (r) => r.isFirst); }),
      ]),
    );
  }
}

// --------------------------
// FILE: lib/themes/custom_themes.dart
// --------------------------
import 'package:flutter/material.dart';

// Animal theme uses earth tones and accent colors
class CustomThemes {
  static final ThemeData animalTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF6D4C41), // brown
    scaffoldBackgroundColor: const Color(0xFFF9F5EE),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF6D4C41)),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D4C41)),
  );
}

// --------------------------
// FILE: lib/screens/business/business_home.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessHome extends StatefulWidget {
  const BusinessHome({super.key});

  @override
  State<BusinessHome> createState() => _BusinessHomeState();
}

class _BusinessHomeState extends State<BusinessHome> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Scaffold(body: const Center(child: Text('Not signed in')));
    return Scaffold(
      appBar: AppBar(title: const Text('Business Home')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _fire.collection('businesses').doc(uid).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final name = d['business_name'] ?? 'Business';
          final desc = d['description'] ?? '';
          final open = d['open'] ?? false;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(desc),
              const SizedBox(height: 12),
              Row(children: [
                Text('Open status: '),
                Switch(value: open, onChanged: (v) async { await _fire.collection('businesses').doc(uid).update({'open': v}); }),
              ]),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessOrders())), child: const Text('View Orders'))
            ]),
          );
        },
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/business/business_orders.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessOrders extends StatelessWidget {
  const BusinessOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Scaffold(body: const Center(child: Text('Not signed in')));
    final stream = FirebaseFirestore.instance.collection('bookings').where('businessId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No orders yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final status = d['status'] ?? 'pending';
              final userId = d['userId'] ?? '';
              final date = d['date'] is Timestamp ? (d['date'] as Timestamp).toDate() : null;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text('Booking from ${d['userName'] ?? userId}'),
                  subtitle: Text('Status: $status\nDate: ${date != null ? date.toLocal().toString().split(' ')[0] : 'N/A'}'),
                  isThreeLine: true,
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (status == 'pending') IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () async => await FirebaseFirestore.instance.collection('bookings').doc(d.id).update({'status': 'confirmed'})),
                    if (status != 'canceled') IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () async => await FirebaseFirestore.instance.collection('bookings').doc(d.id).update({'status': 'canceled'})),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --------------------------
// NOTES & INTEGRATION
// --------------------------
/*
1) Replace any placeholder userId usage in booking creation with:
   final uid = FirebaseAuth.instance.currentUser?.uid;
   and set userName using the user doc or FirebaseAuth displayName.

2) Theme: AppState in services/firebase_service.dart already manages ThemeMode. If you want to support the animal theme, update AppState to hold a custom enum and change MaterialApp to read custom theme when ThemeMode == system (or store it in Firestore user settings). For simplicity, we used ThemeMode.system as a toggle placeholder for "animal theme" in Settings.

3) Wire pages into navigation: add routes or navigate via Navigator.push as in previous files. Example places:
   - User profile: navigate from bottom nav Profile tab
   - My bookings: from bottom nav My List
   - Settings: from Drawer -> Settings

4) Bookings document structure (recommended):
   {
     userId, userName, driverId, driverName, businessId, businessName, date: Timestamp, time: '10:00', notes, status: 'pending'|'confirmed'|'canceled'|'completed', createdAt: FieldValue.serverTimestamp()
   }

5) After copying files, run `flutter pub get` and ensure firebase is initialized. Replace Firebase.initializeApp() call with generated firebase_options if required.

If you want, I can now:
- Update BookingFlow to write full booking payload (userName, businessId) and then show the confirmation flow.
- Implement bottom navigation as a reusable widget and wire profile/bookings tabs to it.
- Implement push notifications skeleton (FCM) and in-app notifications list.

Tell me which of those you'd like next and I'll add them in the same style.
*/


// RooTrails Flutter — Next batch of pages
// Add these files to lib/... and wire imports as shown. This continues from the initial batch.

// PACKAGES needed (ensure in pubspec.yaml):
// provider, firebase_auth, cloud_firestore, intl

// --------------------------
// FILE: lib/screens/user/profile_page.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _loading = true;
  Map<String, dynamic> _data = {};

  final _username = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _fire.collection('users').doc(uid).get();
    _data = doc.data() ?? {};
    _username.text = _data['user_name'] ?? '';
    _first.text = _data['first_name'] ?? '';
    _last.text = _data['last_name'] ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _fire.collection('users').doc(uid).update({
      'user_name': _username.text.trim(),
      'first_name': _first.text.trim(),
      'last_name': _last.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          CircleAvatar(radius: 44, child: Text((_data['user_name'] ?? 'U').toString().isEmpty ? 'U' : (_data['user_name'][0] ?? 'U'))),
          const SizedBox(height: 12),
          TextField(controller: _username, decoration: const InputDecoration(labelText: 'User name')),
          TextField(controller: _first, decoration: const InputDecoration(labelText: 'First name')),
          TextField(controller: _last, decoration: const InputDecoration(labelText: 'Last name')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ]),
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/user/my_bookings.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Scaffold(body: const Center(child: Text('Not signed in')));
    final stream = FirebaseFirestore.instance.collection('bookings').where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No bookings yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final status = d['status'] ?? 'pending';
              final date = d['date'] is Timestamp ? (d['date'] as Timestamp).toDate() : (d['date'] ?? null);
              final dateStr = date != null ? DateFormat.yMMMd().format(date) : 'N/A';
              final time = d['time'] ?? '';
              final driverId = d['driverId'] ?? '';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text('Driver: ${d['driverName'] ?? driverId}'),
                  subtitle: Text('$dateStr • $time\nStatus: $status'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(onSelected: (v) async {
                    if (v == 'cancel') {
                      await FirebaseFirestore.instance.collection('bookings').doc(d.id).update({'status': 'canceled'});
                    }
                  }, itemBuilder: (_) => [const PopupMenuItem(value: 'cancel', child: Text('Cancel'))]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/settings/settings_page.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../themes/custom_themes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        SwitchListTile(
          title: const Text('Dark mode'),
          value: appState.themeMode == ThemeMode.dark,
          onChanged: (v) => appState.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
        ),
        ListTile(
          title: const Text('Animal theme'),
          subtitle: const Text('Apply nature/animal color accents'),
          trailing: ElevatedButton(onPressed: () => appState.setThemeMode(ThemeMode.system), child: const Text('Apply')),
        ),
        ListTile(title: const Text('Contact us'), subtitle: const Text('support@rootrails.app'), onTap: () {}),
        ListTile(title: const Text('Logout'), onTap: () async { await FirebaseService.auth.signOut(); Navigator.popUntil(context, (r) => r.isFirst); }),
      ]),
    );
  }
}

// --------------------------
// FILE: lib/themes/custom_themes.dart
// --------------------------
import 'package:flutter/material.dart';

// Animal theme uses earth tones and accent colors
class CustomThemes {
  static final ThemeData animalTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF6D4C41), // brown
    scaffoldBackgroundColor: const Color(0xFFF9F5EE),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF6D4C41)),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D4C41)),
  );
}

// --------------------------
// FILE: lib/screens/business/business_home.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessHome extends StatefulWidget {
  const BusinessHome({super.key});

  @override
  State<BusinessHome> createState() => _BusinessHomeState();
}

class _BusinessHomeState extends State<BusinessHome> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Scaffold(body: const Center(child: Text('Not signed in')));
    return Scaffold(
      appBar: AppBar(title: const Text('Business Home')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _fire.collection('businesses').doc(uid).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final name = d['business_name'] ?? 'Business';
          final desc = d['description'] ?? '';
          final open = d['open'] ?? false;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(desc),
              const SizedBox(height: 12),
              Row(children: [
                Text('Open status: '),
                Switch(value: open, onChanged: (v) async { await _fire.collection('businesses').doc(uid).update({'open': v}); }),
              ]),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessOrders())), child: const Text('View Orders'))
            ]),
          );
        },
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/business/business_orders.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessOrders extends StatelessWidget {
  const BusinessOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Scaffold(body: const Center(child: Text('Not signed in')));
    final stream = FirebaseFirestore.instance.collection('bookings').where('businessId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No orders yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final status = d['status'] ?? 'pending';
              final userId = d['userId'] ?? '';
              final date = d['date'] is Timestamp ? (d['date'] as Timestamp).toDate() : null;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text('Booking from ${d['userName'] ?? userId}'),
                  subtitle: Text('Status: $status\nDate: ${date != null ? date.toLocal().toString().split(' ')[0] : 'N/A'}'),
                  isThreeLine: true,
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (status == 'pending') IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () async => await FirebaseFirestore.instance.collection('bookings').doc(d.id).update({'status': 'confirmed'})),
                    if (status != 'canceled') IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () async => await FirebaseFirestore.instance.collection('bookings').doc(d.id).update({'status': 'canceled'})),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --------------------------
// NOTES & INTEGRATION
// --------------------------
/*
1) Replace any placeholder userId usage in booking creation with:
   final uid = FirebaseAuth.instance.currentUser?.uid;
   and set userName using the user doc or FirebaseAuth displayName.

2) Theme: AppState in services/firebase_service.dart already manages ThemeMode. If you want to support the animal theme, update AppState to hold a custom enum and change MaterialApp to read custom theme when ThemeMode == system (or store it in Firestore user settings). For simplicity, we used ThemeMode.system as a toggle placeholder for "animal theme" in Settings.

3) Wire pages into navigation: add routes or navigate via Navigator.push as in previous files. Example places:
   - User profile: navigate from bottom nav Profile tab
   - My bookings: from bottom nav My List
   - Settings: from Drawer -> Settings

4) Bookings document structure (recommended):
   {
     userId, userName, driverId, driverName, businessId, businessName, date: Timestamp, time: '10:00', notes, status: 'pending'|'confirmed'|'canceled'|'completed', createdAt: FieldValue.serverTimestamp()
   }

5) After copying files, run `flutter pub get` and ensure firebase is initialized. Replace Firebase.initializeApp() call with generated firebase_options if required.

If you want, I can now:
- Update BookingFlow to write full booking payload (userName, businessId) and then show the confirmation flow.
- Implement bottom navigation as a reusable widget and wire profile/bookings tabs to it.
- Implement push notifications skeleton (FCM) and in-app notifications list.

Tell me which of those you'd like next and I'll add them in the same style.

*/
// --------------------------
// ADDITIONAL: Bottom Navigation + Updated BookingFlow + Navigation Page
// Append these new files to your lib/ folder. Replace the previous booking_flow.dart with the updated version below.

// --------------------------
// FILE: lib/widgets/bottom_nav.dart
// --------------------------
import 'package:flutter/material.dart';

typedef OnTabSelected = void Function(int index);

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final OnTabSelected onTap;
  const AppBottomNavigation({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My List'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Navigation'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}


// --------------------------
// FILE: lib/screens/navigation/navigation_page.dart
// --------------------------
import 'package:flutter/material.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
      body: const Center(child: Text('Main navigation and map logic will go here.
You can add route planning, nearby parks, and directions.')),
    );
  }
}


// --------------------------
// FILE: lib/screens/user/booking_flow.dart (REPLACE previous booking_flow.dart with this file)
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../user/driver_page.dart';
import '../payment/dummy_payment.dart';

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
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getUserDoc() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};
    final snap = await _fire.collection('users').doc(uid).get();
    return snap.data() ?? {};
  }

  Future<void> _createBooking() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be signed in to book.')));
      return;
    }
    if (selectedTime == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select time and date')));
      return;
    }

    setState(() => _loading = true);

    // get user info
    final userDoc = await _getUserDoc();
    final userName = userDoc['user_name'] ?? _auth.currentUser?.displayName ?? '';

    // get driver and business info
    final driverSnap = await _fire.collection('drivers').doc(widget.driverId).get();
    final driver = driverSnap.data() ?? {};
    final driverName = driver['name'] ?? '';
    final businessId = driver['businessId'] ?? null;
    final businessName = '';

    final bookingData = {
      'driverId': widget.driverId,
      'driverName': driverName,
      'userId': uid,
      'userName': userName,
      'businessId': businessId,
      'time': selectedTime,
      'date': Timestamp.fromDate(DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day)),
      'notes': _notes.text.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _fire.collection('bookings').add(bookingData);

    // Create an in-app notification document for the business (optional)
    if (businessId != null) {
      await _fire.collection('notifications').add({
        'to': businessId,
        'type': 'new_booking',
        'bookingId': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    }

    // Proceed to payment screen (dummy). If payment succeeds, update booking status to 'confirmed'
    final paid = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DummyPayment()));
    if (paid == true) {
      await _fire.collection('bookings').doc(docRef.id).update({'status': 'confirmed', 'paidAt': FieldValue.serverTimestamp()});
    }

    setState(() => _loading = false);

    // goto home or show success
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created')));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text(selectedDate == null ? 'Select Date' : DateFormat.yMMMd().format(selectedDate!)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (d != null) setState(() => selectedDate = d);
            },
          ),
          const SizedBox(height: 12),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes (optional)')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loading ? null : _createBooking, child: _loading ? const CircularProgressIndicator() : const Text('Book now'))
        ]),
      ),
    );
  }
}


// --------------------------
// FILE: lib/screens/payment/dummy_payment.dart
// --------------------------
import 'package:flutter/material.dart';

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
// INTEGRATION INSTRUCTIONS
// --------------------------
/*
1) Replace the old booking_flow.dart with the new file above (lib/screens/user/booking_flow.dart). It now uses FirebaseAuth for current user, writes a complete booking document, and creates a simple notification document for the business.

2) Add the new widgets and pages to your project:
   - lib/widgets/bottom_nav.dart
   - lib/screens/navigation/navigation_page.dart
   - lib/screens/payment/dummy_payment.dart

3) Wire the Bottom Navigation into UserHome and BusinessHome.
   Example (UserHome):
     - Convert UserHomePage to a stateful widget that holds an _currentIndex.
     - Replace the bottomNavigationBar with: AppBottomNavigation(currentIndex: _currentIndex, onTap: (i) { setState(() => _currentIndex = i); /* navigate or swap pages */ });

   Quick snippet for UserHome main scaffold replacement:
     int _currentIndex = 0; // inside state
     final pages = [HomeContent(), MyBookingsPage(), NavigationPage(), ProfilePage()];
     body: pages[_currentIndex],
     bottomNavigationBar: AppBottomNavigation(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i));

4) Ensure your `drivers` collection documents include fields: name, imageUrl, price, rating, open (bool), parkId, businessId.

5) Ensure your `bookings` security rules and structure are set in Firestore.

If you'd like, I can now:
- Update the UserHome and BusinessHome files in the canvas to the fully stateful bottom-nav versions (I recommend this next so everything is wired). 
- Implement driver management (CRUD) for business users.

Tell me to proceed and I will update the UserHome and BusinessHome files in the document to include the bottom navigation and page swapping.

*/


import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/user_drawer.dart';
import '../../widgets/user_appbar.dart';
import 'park_page.dart';
import '../../widgets/bottom_nav.dart';
import '../user/my_bookings.dart';
import '../navigation/navigation_page.dart';
import 'profile_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentIndex = 0;
  final _fire = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeContent(fire: _fire),
      const MyBookingsPage(),
      const NavigationPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: const UserAppBar(title: 'RooTrails'),
      drawer: const UserDrawer(),
      body: pages[_currentIndex],
      bottomNavigationBar:
          AppBottomNavigation(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
    );
  }
}

class HomeContent extends StatelessWidget {
  final FirebaseFirestore fire;
  const HomeContent({super.key, required this.fire});

  bool _isOpen(String from, String to) {
    try {
      final now = TimeOfDay.now();
      final f = _parse(from);
      final t = _parse(to);
      final nMinutes = now.hour * 60 + now.minute;
      final fMinutes = f.hour * 60 + f.minute;
      final tMinutes = t.hour * 60 + t.minute;
      if (fMinutes <= tMinutes) return nMinutes >= fMinutes && nMinutes <= tMinutes;
      return nMinutes >= fMinutes || nMinutes <= tMinutes;
    } catch (e) {
      return false;
    }
  }

  TimeOfDay _parse(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Carousel from firestore: collection 'carousel_images' documents contain field 'imageUrl'
          StreamBuilder<QuerySnapshot>(
            stream: fire.collection('carousel_images').orderBy('order', descending: false).snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
              final docs = snap.data!.docs;
              final urls = docs.map((d) => d['imageUrl'] as String).toList();
              if (urls.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No images available')));
              return CarouselSlider(
                options: CarouselOptions(height: 200, autoPlay: true, enlargeCenterPage: true),
                items: urls
                    .map((u) => ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration:
                                BoxDecoration(boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)], borderRadius: BorderRadius.circular(16)),
                            child: Image.network(u, fit: BoxFit.cover, width: double.infinity),
                          ),
                        ))
                    .toList(),
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
              stream: fire.collection('parks').snapshots(),
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
              stream: fire.collection('businesses').snapshots(),
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
    );
  }
}



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/bottom_nav.dart';
import '../navigation/navigation_page.dart';
import 'business_orders.dart';
import '../../screens/user/profile_page.dart'; // reuse profile for now

class BusinessHomePage extends StatefulWidget {
  const BusinessHomePage({super.key});

  @override
  State<BusinessHomePage> createState() => _BusinessHomePageState();
}

class _BusinessHomePageState extends State<BusinessHomePage> {
  int _currentIndex = 0;
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BusinessHomeContent(fire: _fire, auth: _auth),
      const BusinessOrders(),
      const NavigationPage(),
      const ProfilePage(), // temporary: you can create BusinessProfile later
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Business')),
      body: pages[_currentIndex],
      bottomNavigationBar:
          AppBottomNavigation(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
    );
  }
}

class BusinessHomeContent extends StatelessWidget {
  final FirebaseFirestore fire;
  final FirebaseAuth auth;
  const BusinessHomeContent({super.key, required this.fire, required this.auth});

  @override
  Widget build(BuildContext context) {
    final uid = auth.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Not signed in'));

    return StreamBuilder<DocumentSnapshot>(
      stream: fire.collection('businesses').doc(uid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final d = snap.data!;
        final name = d['business_name'] ?? 'Business';
        final desc = d['description'] ?? '';
        final open = d['open'] ?? false;
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Open status: '),
              Switch(value: open, onChanged: (v) async { await fire.collection('businesses').doc(uid).update({'open': v}); }),
            ]),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessOrders())), child: const Text('View Orders')),
          ]),
        );
      },
    );
  }
}




// RooTrails Flutter — Next batch of pages
// Add these files to lib/... and wire imports as shown. This continues from the initial batch.

// PACKAGES needed (ensure in pubspec.yaml):
// provider, firebase_auth, cloud_firestore, intl

// --------------------------
// FILE: lib/screens/user/profile_page.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _loading = true;
  Map<String, dynamic> _data = {};

  final _username = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _fire.collection('users').doc(uid).get();
    _data = doc.data() ?? {};
    _username.text = _data['user_name'] ?? '';
    _first.text = _data['first_name'] ?? '';
    _last.text = _data['last_name'] ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _fire.collection('users').doc(uid).update({
      'user_name': _username.text.trim(),
      'first_name': _first.text.trim(),
      'last_name': _last.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          CircleAvatar(radius: 44, child: Text((_data['user_name'] ?? 'U').toString().isEmpty ? 'U' : (_data['user_name'][0] ?? 'U'))),
          const SizedBox(height: 12),
          TextField(controller: _username, decoration: const InputDecoration(labelText: 'User name')),
          TextField(controller: _first, decoration: const InputDecoration(labelText: 'First name')),
          TextField(controller: _last, decoration: const InputDecoration(labelText: 'Last name')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ]),
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/user/my_bookings.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Scaffold(body: const Center(child: Text('Not signed in')));
    final stream = FirebaseFirestore.instance.collection('bookings').where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No bookings yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final status = d['status'] ?? 'pending';
              final date = d['date'] is Timestamp ? (d['date'] as Timestamp).toDate() : (d['date'] ?? null);
              final dateStr = date != null ? DateFormat.yMMMd().format(date) : 'N/A';
              final time = d['time'] ?? '';
              final driverId = d['driverId'] ?? '';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text('Driver: ${d['driverName'] ?? driverId}'),
                  subtitle: Text('$dateStr • $time\nStatus: $status'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(onSelected: (v) async {
                    if (v == 'cancel') {
                      await FirebaseFirestore.instance.collection('bookings').doc(d.id).update({'status': 'canceled'});
                    }
                  }, itemBuilder: (_) => [const PopupMenuItem(value: 'cancel', child: Text('Cancel'))]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/settings/settings_page.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../themes/custom_themes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        SwitchListTile(
          title: const Text('Dark mode'),
          value: appState.themeMode == ThemeMode.dark,
          onChanged: (v) => appState.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
        ),
        ListTile(
          title: const Text('Animal theme'),
          subtitle: const Text('Apply nature/animal color accents'),
          trailing: ElevatedButton(onPressed: () => appState.setThemeMode(ThemeMode.system), child: const Text('Apply')),
        ),
        ListTile(title: const Text('Contact us'), subtitle: const Text('support@rootrails.app'), onTap: () {}),
        ListTile(title: const Text('Logout'), onTap: () async { await FirebaseService.auth.signOut(); Navigator.popUntil(context, (r) => r.isFirst); }),
      ]),
    );
  }
}

// --------------------------
// FILE: lib/themes/custom_themes.dart
// --------------------------
import 'package:flutter/material.dart';

// Animal theme uses earth tones and accent colors
class CustomThemes {
  static final ThemeData animalTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF6D4C41), // brown
    scaffoldBackgroundColor: const Color(0xFFF9F5EE),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF6D4C41)),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D4C41)),
  );
}

// --------------------------
// FILE: lib/screens/business/business_home.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessHome extends StatefulWidget {
  const BusinessHome({super.key});

  @override
  State<BusinessHome> createState() => _BusinessHomeState();
}

class _BusinessHomeState extends State<BusinessHome> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Scaffold(body: const Center(child: Text('Not signed in')));
    return Scaffold(
      appBar: AppBar(title: const Text('Business Home')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _fire.collection('businesses').doc(uid).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final name = d['business_name'] ?? 'Business';
          final desc = d['description'] ?? '';
          final open = d['open'] ?? false;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(desc),
              const SizedBox(height: 12),
              Row(children: [
                Text('Open status: '),
                Switch(value: open, onChanged: (v) async { await _fire.collection('businesses').doc(uid).update({'open': v}); }),
              ]),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessOrders())), child: const Text('View Orders'))
            ]),
          );
        },
      ),
    );
  }
}

// --------------------------
// FILE: lib/screens/business/business_orders.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessOrders extends StatelessWidget {
  const BusinessOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Scaffold(body: const Center(child: Text('Not signed in')));
    final stream = FirebaseFirestore.instance.collection('bookings').where('businessId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No orders yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final status = d['status'] ?? 'pending';
              final userId = d['userId'] ?? '';
              final date = d['date'] is Timestamp ? (d['date'] as Timestamp).toDate() : null;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text('Booking from ${d['userName'] ?? userId}'),
                  subtitle: Text('Status: $status\nDate: ${date != null ? date.toLocal().toString().split(' ')[0] : 'N/A'}'),
                  isThreeLine: true,
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (status == 'pending') IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () async => await FirebaseFirestore.instance.collection('bookings').doc(d.id).update({'status': 'confirmed'})),
                    if (status != 'canceled') IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () async => await FirebaseFirestore.instance.collection('bookings').doc(d.id).update({'status': 'canceled'})),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --------------------------
// NOTES & INTEGRATION
// --------------------------
/*
1) Replace any placeholder userId usage in booking creation with:
   final uid = FirebaseAuth.instance.currentUser?.uid;
   and set userName using the user doc or FirebaseAuth displayName.

2) Theme: AppState in services/firebase_service.dart already manages ThemeMode. If you want to support the animal theme, update AppState to hold a custom enum and change MaterialApp to read custom theme when ThemeMode == system (or store it in Firestore user settings). For simplicity, we used ThemeMode.system as a toggle placeholder for "animal theme" in Settings.

3) Wire pages into navigation: add routes or navigate via Navigator.push as in previous files. Example places:
   - User profile: navigate from bottom nav Profile tab
   - My bookings: from bottom nav My List
   - Settings: from Drawer -> Settings

4) Bookings document structure (recommended):
   {
     userId, userName, driverId, driverName, businessId, businessName, date: Timestamp, time: '10:00', notes, status: 'pending'|'confirmed'|'canceled'|'completed', createdAt: FieldValue.serverTimestamp()
   }

5) After copying files, run `flutter pub get` and ensure firebase is initialized. Replace Firebase.initializeApp() call with generated firebase_options if required.

If you want, I can now:
- Update BookingFlow to write full booking payload (userName, businessId) and then show the confirmation flow.
- Implement bottom navigation as a reusable widget and wire profile/bookings tabs to it.
- Implement push notifications skeleton (FCM) and in-app notifications list.

Tell me which of those you'd like next and I'll add them in the same style.
*/

// --------------------------
// ADDITIONAL: Bottom Navigation + Updated BookingFlow + Navigation Page
// Append these new files to your lib/ folder. Replace the previous booking_flow.dart with the updated version below.

// --------------------------
// FILE: lib/widgets/bottom_nav.dart
// --------------------------
import 'package:flutter/material.dart';

typedef OnTabSelected = void Function(int index);

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final OnTabSelected onTap;
  const AppBottomNavigation({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My List'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Navigation'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}


// --------------------------
// FILE: lib/screens/navigation/navigation_page.dart
// --------------------------
import 'package:flutter/material.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
      body: const Center(child: Text('Main navigation and map logic will go here.
You can add route planning, nearby parks, and directions.')),
    );
  }
}


// --------------------------
// FILE: lib/screens/user/booking_flow.dart (REPLACE previous booking_flow.dart with this file)
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../user/driver_page.dart';
import '../payment/dummy_payment.dart';

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
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getUserDoc() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};
    final snap = await _fire.collection('users').doc(uid).get();
    return snap.data() ?? {};
  }

  Future<void> _createBooking() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be signed in to book.')));
      return;
    }
    if (selectedTime == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select time and date')));
      return;
    }

    setState(() => _loading = true);

    // get user info
    final userDoc = await _getUserDoc();
    final userName = userDoc['user_name'] ?? _auth.currentUser?.displayName ?? '';

    // get driver and business info
    final driverSnap = await _fire.collection('drivers').doc(widget.driverId).get();
    final driver = driverSnap.data() ?? {};
    final driverName = driver['name'] ?? '';
    final businessId = driver['businessId'] ?? null;
    final businessName = '';

    final bookingData = {
      'driverId': widget.driverId,
      'driverName': driverName,
      'userId': uid,
      'userName': userName,
      'businessId': businessId,
      'time': selectedTime,
      'date': Timestamp.fromDate(DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day)),
      'notes': _notes.text.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _fire.collection('bookings').add(bookingData);

    // Create an in-app notification document for the business (optional)
    if (businessId != null) {
      await _fire.collection('notifications').add({
        'to': businessId,
        'type': 'new_booking',
        'bookingId': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    }

    // Proceed to payment screen (dummy). If payment succeeds, update booking status to 'confirmed'
    final paid = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DummyPayment()));
    if (paid == true) {
      await _fire.collection('bookings').doc(docRef.id).update({'status': 'confirmed', 'paidAt': FieldValue.serverTimestamp()});
    }

    setState(() => _loading = false);

    // goto home or show success
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created')));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text(selectedDate == null ? 'Select Date' : DateFormat.yMMMd().format(selectedDate!)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (d != null) setState(() => selectedDate = d);
            },
          ),
          const SizedBox(height: 12),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes (optional)')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loading ? null : _createBooking, child: _loading ? const CircularProgressIndicator() : const Text('Book now'))
        ]),
      ),
    );
  }
}


// --------------------------
// FILE: lib/screens/payment/dummy_payment.dart
// --------------------------
import 'package:flutter/material.dart';

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
// INTEGRATION INSTRUCTIONS
// --------------------------
/*
1) Replace the old booking_flow.dart with the new file above (lib/screens/user/booking_flow.dart). It now uses FirebaseAuth for current user, writes a complete booking document, and creates a simple notification document for the business.

2) Add the new widgets and pages to your project:
   - lib/widgets/bottom_nav.dart
   - lib/screens/navigation/navigation_page.dart
   - lib/screens/payment/dummy_payment.dart

3) Wire the Bottom Navigation into UserHome and BusinessHome.
   Example (UserHome):
     - Convert UserHomePage to a stateful widget that holds an _currentIndex.
     - Replace the bottomNavigationBar with: AppBottomNavigation(currentIndex: _currentIndex, onTap: (i) { setState(() => _currentIndex = i); /* navigate or swap pages */ });

   Quick snippet for UserHome main scaffold replacement:
     int _currentIndex = 0; // inside state
     final pages = [HomeContent(), MyBookingsPage(), NavigationPage(), ProfilePage()];
     body: pages[_currentIndex],
     bottomNavigationBar: AppBottomNavigation(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i));

4) Ensure your `drivers` collection documents include fields: name, imageUrl, price, rating, open (bool), parkId, businessId.

5) Ensure your `bookings` security rules and structure are set in Firestore.

If you'd like, I can now:
- Update the UserHome and BusinessHome files in the canvas to the fully stateful bottom-nav versions (I recommend this next so everything is wired). 
- Implement driver management (CRUD) for business users.

Tell me to proceed and I will update the UserHome and BusinessHome files in the document to include the bottom navigation and page swapping.
*/

// --------------------------
// FILE: lib/screens/business/business_profile.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessProfile extends StatefulWidget {
  const BusinessProfile({super.key});

  @override
  State<BusinessProfile> createState() => _BusinessProfileState();
}

class _BusinessProfileState extends State<BusinessProfile> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _image = TextEditingController();
  final _driverImage = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController();
  final _location = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _fire.collection('businesses').doc(uid).get();
    final data = doc.data() ?? {};
    _name.text = data['business_name'] ?? '';
    _desc.text = data['description'] ?? '';
    _image.text = data['imageUrl'] ?? '';
    _driverImage.text = data['driverImageUrl'] ?? '';
    _price.text = (data['price'] ?? '').toString();
    _duration.text = data['duration'] ?? '';
    _location.text = data['location'] ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _fire.collection('businesses').doc(uid).update({
      'business_name': _name.text.trim(),
      'description': _desc.text.trim(),
      'imageUrl': _image.text.trim(),
      'driverImageUrl': _driverImage.text.trim(),
      'price': double.tryParse(_price.text) ?? 0,
      'duration': _duration.text.trim(),
      'location': _location.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business updated')));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Business')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Business name')),
          const SizedBox(height: 8),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          const SizedBox(height: 8),
          TextField(controller: _image, decoration: const InputDecoration(labelText: 'Business image URL')),
          const SizedBox(height: 8),
          TextField(controller: _driverImage, decoration: const InputDecoration(labelText: 'Default driver image URL')),
          const SizedBox(height: 8),
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Default price')),
          const SizedBox(height: 8),
          TextField(controller: _duration, decoration: const InputDecoration(labelText: 'Duration (e.g. 3 hours)')),
          const SizedBox(height: 8),
          TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location (maps url or lat,lng)')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Save'))
        ]),
      ),
    );
  }
}


// --------------------------
// FILE: lib/screens/business/driver_management.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'driver_form.dart';

class DriverManagement extends StatelessWidget {
  const DriverManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Scaffold(body: const Center(child: Text('Not signed in')));
    final stream = FirebaseFirestore.instance.collection('drivers').where('businessId', isEqualTo: uid).snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Drivers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriverForm())),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No drivers yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: d['imageUrl'] != null && d['imageUrl'] != '' ? CircleAvatar(backgroundImage: NetworkImage(d['imageUrl'])) : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(d['name'] ?? 'Driver'),
                  subtitle: Text('\$${d['price'] ?? '0'} • ${d['rating'] ?? '4.0'} ★'),
                  trailing: PopupMenuButton<String>(onSelected: (v) async {
                    if (v == 'edit') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DriverForm(driverId: d.id)));
                    } else if (v == 'delete') {
                      await FirebaseFirestore.instance.collection('drivers').doc(d.id).delete();
                    }
                  }, itemBuilder: (_) => [const PopupMenuItem(value: 'edit', child: Text('Edit')), const PopupMenuItem(value: 'delete', child: Text('Delete'))]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


// --------------------------
// FILE: lib/screens/business/driver_form.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverForm extends StatefulWidget {
  final String? driverId;
  const DriverForm({super.key, this.driverId});

  @override
  State<DriverForm> createState() => _DriverFormState();
}

class _DriverFormState extends State<DriverForm> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _name = TextEditingController();
  final _image = TextEditingController();
  final _price = TextEditingController();
  final _rating = TextEditingController(text: '4.0');
  final _bio = TextEditingController();
  bool _open = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.driverId != null) _load(); else _loading = false;
  }

  Future<void> _load() async {
    final doc = await _fire.collection('drivers').doc(widget.driverId).get();
    final data = doc.data() ?? {};
    _name.text = data['name'] ?? '';
    _image.text = data['imageUrl'] ?? '';
    _price.text = (data['price'] ?? '').toString();
    _rating.text = (data['rating'] ?? '4.0').toString();
    _bio.text = data['bio'] ?? '';
    _open = data['open'] ?? true;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final data = {
      'name': _name.text.trim(),
      'imageUrl': _image.text.trim(),
      'price': double.tryParse(_price.text) ?? 0,
      'rating': double.tryParse(_rating.text) ?? 4.0,
      'bio': _bio.text.trim(),
      'open': _open,
      'businessId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (widget.driverId == null) {
      await _fire.collection('drivers').add(data);
    } else {
      await _fire.collection('drivers').doc(widget.driverId).update(data);
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.driverId == null ? 'Add Driver' : 'Edit Driver')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 8),
          TextField(controller: _image, decoration: const InputDecoration(labelText: 'Image URL')),
          const SizedBox(height: 8),
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price')),
          const SizedBox(height: 8),
          TextField(controller: _rating, decoration: const InputDecoration(labelText: 'Rating')),
          const SizedBox(height: 8),
          TextField(controller: _bio, decoration: const InputDecoration(labelText: 'Short bio'), maxLines: 3),
          const SizedBox(height: 12),
          SwitchListTile(title: const Text('Open for bookings'), value: _open, onChanged: (v) => setState(() => _open = v)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _save, child: const Text('Save'))
        ]),
      ),
    );
  }
}


// --------------------------
// INTEGRATION NOTES
// --------------------------
/*
1) Add new routes or import these pages where needed.
   - From BusinessHome (business_home.dart) replace the "View Orders" button or add new buttons:
       ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessProfile())), child: Text('Edit Business'))
       ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverManagement())), child: Text('Manage Drivers'))

2) Driver documents created include businessId so they automatically appear in Park pages when filtered by parkId or businessId.

3) You can extend the driver schema with fields like 'parkId', 'vehicle', 'languages', etc.

4) Security rules: ensure only the business owner (doc id == auth.uid) can add/update/delete their drivers and business doc.

5) After copying these files, run `flutter pub get`. Let me know if you want me to update BusinessHome in the canvas to include the new buttons — I can patch that file too so everything is wired.
*/


// --------------------------
// PATCH: Updated Business Home (wired to BusinessProfile & Driver Management)
// FILE: lib/screens/business/business_home.dart
// --------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/bottom_nav.dart';
import '../navigation/navigation_page.dart';
import 'business_orders.dart';
import 'business_profile.dart';
import 'driver_management.dart';

class BusinessHomePage extends StatefulWidget {
  const BusinessHomePage({super.key});

  @override
  State<BusinessHomePage> createState() => _BusinessHomePageState();
}

class _BusinessHomePageState extends State<BusinessHomePage> {
  int _currentIndex = 0;
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BusinessHomeContent(fire: _fire, auth: _auth),
      const BusinessOrders(),
      const NavigationPage(),
      const SizedBox(), // placeholder for profile/business account page
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Business')),
      body: pages[_currentIndex],
      bottomNavigationBar:
          AppBottomNavigation(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
    );
  }
}

class BusinessHomeContent extends StatelessWidget {
  final FirebaseFirestore fire;
  final FirebaseAuth auth;
  const BusinessHomeContent({super.key, required this.fire, required this.auth});

  @override
  Widget build(BuildContext context) {
    final uid = auth.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Not signed in'));

    return StreamBuilder<DocumentSnapshot>(
      stream: fire.collection('businesses').doc(uid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final d = snap.data!;
        final name = d['business_name'] ?? 'Business';
        final desc = d['description'] ?? '';
        final open = d['open'] ?? false;
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Open status: '),
              Switch(value: open, onChanged: (v) async { await fire.collection('businesses').doc(uid).update({'open': v}); }),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 12, children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Business'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessProfile())),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Manage Drivers'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverManagement())),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Assign Park'),
                onPressed: () => _showAssignParkDialog(context, fire, uid),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('View Orders'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessOrders())),
              ),
            ]),
            const SizedBox(height: 16),
            const Text('Quick actions', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // additional quick action UI could go here
          ]),
        );
      },
    );
  }

  void _showAssignParkDialog(BuildContext context, FirebaseFirestore fire, String businessId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Park'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: fire.collection('parks').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                final docs = snap.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final p = docs[index];
                    return ListTile(
                      title: Text(p['name'] ?? 'Park'),
                      subtitle: Text(p['description'] ?? ''),
                      onTap: () async {
                        // assign this business to the park (add businessId to park's list or set field)
                        await fire.collection('parks').doc(p.id).update({
                          'businesses': FieldValue.arrayUnion([businessId])
                        });
                        // optionally add parkId to business doc
                        await fire.collection('businesses').doc(businessId).update({'parkId': p.id});
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assigned to park')));
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
        );
      },
    );
  }
}


// --------------------------
// SUGGESTED FIRESTORE SECURITY RULES (example)
// --------------------------
/*
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user doc
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Businesses: only the owner can write; read by anyone
    match /businesses/{businessId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == businessId;
    }

    // Drivers: only the business owner can write drivers belonging to them
    match /drivers/{driverId} {
      allow read: if true;
      allow write: if request.auth != null && (
        // If creating, ensure businessId matches auth.uid
        (request.resource != null && request.resource.data.businessId == request.auth.uid) ||
        // If updating/deleting, ensure stored businessId matches auth.uid
        (resource.data.businessId == request.auth.uid)
      );
    }

    // Bookings: user can create booking with their UID, business can read bookings for their business
    match /bookings/{bookingId} {
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow read: if request.auth != null && (resource.data.userId == request.auth.uid || resource.data.businessId == request.auth.uid || resource.data.driverId == request.auth.uid);
      allow update: if request.auth != null && (resource.data.businessId == request.auth.uid || resource.data.userId == request.auth.uid);
      allow delete: if false;
    }

    // Notifications: only intended recipient can read/write their notifications
    match /notifications/{notifId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && resource.data.to == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.to == request.auth.uid;
    }
  }
}
*/

// --------------------------
// END PATCH
// --------------------------


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/bottom_nav.dart';
import '../navigation/navigation_page.dart';
import 'business_orders.dart';
import 'business_profile.dart';
import 'driver_management.dart';
import 'business_profile_tab.dart';

class BusinessHomePage extends StatefulWidget {
  const BusinessHomePage({super.key});

  @override
  State<BusinessHomePage> createState() => _BusinessHomePageState();
}

class _BusinessHomePageState extends State<BusinessHomePage> {
  int _currentIndex = 0;
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BusinessHomeContent(fire: _fire, auth: _auth),
      const BusinessOrders(),
      const NavigationPage(),
      const BusinessProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Business')),
      body: pages[_currentIndex],
      bottomNavigationBar:
          AppBottomNavigation(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
    );
  }
}

class BusinessHomeContent extends StatelessWidget {
  final FirebaseFirestore fire;
  final FirebaseAuth auth;
  const BusinessHomeContent({super.key, required this.fire, required this.auth});

  @override
  Widget build(BuildContext context) {
    final uid = auth.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Not signed in'));

    return StreamBuilder<DocumentSnapshot>(
      stream: fire.collection('businesses').doc(uid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final d = snap.data!;
        final name = d['business_name'] ?? 'Business';
        final desc = d['description'] ?? '';
        final open = d['open'] ?? false;
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Open status: '),
              Switch(value: open, onChanged: (v) async { await fire.collection('businesses').doc(uid).update({'open': v}); }),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 12, children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Business'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessProfile())),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Manage Drivers'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverManagement())),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Assign Park'),
                onPressed: () => _showAssignParkDialog(context, fire, uid),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('View Orders'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessOrders())),
              ),
            ]),
            const SizedBox(height: 16),
            const Text('Quick actions', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // extra UI could go here
          ]),
        );
      },
    );
  }

  void _showAssignParkDialog(BuildContext context, FirebaseFirestore fire, String businessId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Park'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: fire.collection('parks').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                final docs = snap.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final p = docs[index];
                    return ListTile(
                      title: Text(p['name'] ?? 'Park'),
                      subtitle: Text(p['description'] ?? ''),
                      onTap: () async {
                        await fire.collection('parks').doc(p.id).update({
                          'businesses': FieldValue.arrayUnion([businessId])
                        });
                        await fire.collection('businesses').doc(businessId).update({'parkId': p.id});
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assigned to park')));
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
        );
      },
    );
  }
}



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessProfile extends StatefulWidget {
  const BusinessProfile({super.key});

  @override
  State<BusinessProfile> createState() => _BusinessProfileState();
}

class _BusinessProfileState extends State<BusinessProfile> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _image = TextEditingController();
  final _driverImage = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController();
  final _location = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _fire.collection('businesses').doc(uid).get();
    final data = doc.data() ?? {};
    _name.text = data['business_name'] ?? '';
    _desc.text = data['description'] ?? '';
    _image.text = data['imageUrl'] ?? '';
    _driverImage.text = data['driverImageUrl'] ?? '';
    _price.text = (data['price'] ?? '').toString();
    _duration.text = data['duration'] ?? '';
    _location.text = data['location'] ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _fire.collection('businesses').doc(uid).update({
      'business_name': _name.text.trim(),
      'description': _desc.text.trim(),
      'imageUrl': _image.text.trim(),
      'driverImageUrl': _driverImage.text.trim(),
      'price': double.tryParse(_price.text) ?? 0,
      'duration': _duration.text.trim(),
      'location': _location.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business updated')));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Business')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Business name')),
          const SizedBox(height: 8),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          const SizedBox(height: 8),
          TextField(controller: _image, decoration: const InputDecoration(labelText: 'Business image URL')),
          const SizedBox(height: 8),
          TextField(controller: _driverImage, decoration: const InputDecoration(labelText: 'Default driver image URL')),
          const SizedBox(height: 8),
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Default price')),
          const SizedBox(height: 8),
          TextField(controller: _duration, decoration: const InputDecoration(labelText: 'Duration (e.g. 3 hours)')),
          const SizedBox(height: 8),
          TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location (maps url or lat,lng)')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Save'))
        ]),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'driver_form.dart';

class DriverManagement extends StatelessWidget {
  const DriverManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Scaffold(body: const Center(child: Text('Not signed in')));
    final stream = FirebaseFirestore.instance.collection('drivers').where('businessId', isEqualTo: uid).snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Drivers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverForm())),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No drivers yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: (d['imageUrl'] != null && (d['imageUrl'] as String).isNotEmpty)
                      ? CircleAvatar(backgroundImage: NetworkImage(d['imageUrl']))
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(d['name'] ?? 'Driver'),
                  subtitle: Text('\$${d['price'] ?? '0'} • ${d['rating'] ?? '4.0'} ★'),
                  trailing: PopupMenuButton<String>(onSelected: (v) async {
                    if (v == 'edit') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DriverForm(driverId: d.id)));
                    } else if (v == 'delete') {
                      await FirebaseFirestore.instance.collection('drivers').doc(d.id).delete();
                    }
                  }, itemBuilder: (_) => [const PopupMenuItem(value: 'edit', child: Text('Edit')), const PopupMenuItem(value: 'delete', child: Text('Delete'))]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverForm extends StatefulWidget {
  final String? driverId;
  const DriverForm({super.key, this.driverId});

  @override
  State<DriverForm> createState() => _DriverFormState();
}

class _DriverFormState extends State<DriverForm> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _name = TextEditingController();
  final _image = TextEditingController();
  final _price = TextEditingController();
  final _rating = TextEditingController(text: '4.0');
  final _bio = TextEditingController();
  bool _open = true;
  bool _loading = true;
  List<String> _selectedParkIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.driverId != null) _load(); else _loading = false;
  }

  Future<void> _load() async {
    final doc = await _fire.collection('drivers').doc(widget.driverId).get();
    final data = doc.data() ?? {};
    _name.text = data['name'] ?? '';
    _image.text = data['imageUrl'] ?? '';
    _price.text = (data['price'] ?? '').toString();
    _rating.text = (data['rating'] ?? '4.0').toString();
    _bio.text = data['bio'] ?? '';
    _open = data['open'] ?? true;
    _selectedParkIds = List<String>.from(data['parkIds'] ?? []);
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final data = {
      'name': _name.text.trim(),
      'imageUrl': _image.text.trim(),
      'price': double.tryParse(_price.text) ?? 0,
      'rating': double.tryParse(_rating.text) ?? 4.0,
      'bio': _bio.text.trim(),
      'open': _open,
      'businessId': uid,
      'parkIds': _selectedParkIds,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (widget.driverId == null) {
      await _fire.collection('drivers').add(data);
    } else {
      await _fire.collection('drivers').doc(widget.driverId).update(data);
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.driverId == null ? 'Add Driver' : 'Edit Driver')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 8),
          TextField(controller: _image, decoration: const InputDecoration(labelText: 'Image URL')),
          const SizedBox(height: 8),
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price')),
          const SizedBox(height: 8),
          TextField(controller: _rating, decoration: const InputDecoration(labelText: 'Rating')),
          const SizedBox(height: 8),
          TextField(controller: _bio, decoration: const InputDecoration(labelText: 'Short bio'), maxLines: 3),
          const SizedBox(height: 12),
          SwitchListTile(title: const Text('Open for bookings'), value: _open, onChanged: (v) => setState(() => _open = v)),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: Text('Assign to parks', style: Theme.of(context).textTheme.subtitle1)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: _fire.collection('parks').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const CircularProgressIndicator();
              final parks = snap.data!.docs;
              return Wrap(
                spacing: 8,
                children: parks.map((p) {
                  final pid = p.id;
                  final name = p['name'] ?? 'Park';
                  final selected = _selectedParkIds.contains(pid);
                  return FilterChip(
                    label: Text(name),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) _selectedParkIds.add(pid);
                        else _selectedParkIds.remove(pid);
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Save'))
        ]),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'business_profile.dart';

class BusinessProfileTab extends StatelessWidget {
  const BusinessProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Not signed in'));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('businesses').doc(uid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final d = snap.data!;
        final name = d['business_name'] ?? '';
        final image = d['imageUrl'] ?? '';
        final price = d['price'] ?? 0;
        final parkId = d['parkId'] ?? '';
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 36, backgroundImage: image != '' ? NetworkImage(image) : null, child: image == '' ? const Icon(Icons.store) : null),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text('From \$${price.toString()}')])),
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessProfile())), child: const Text('Edit'))
            ]),
            const SizedBox(height: 16),
            Text('Assigned park: ${parkId.isEmpty ? 'None' : parkId}'),
            const SizedBox(height: 12),
            const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bookings').where('businessId', isEqualTo: uid).snapshots(),
              builder: (context, snap2) {
                if (!snap2.hasData) return const SizedBox();
                final docs = snap2.data!.docs;
                final total = docs.length;
                final confirmed = docs.where((b) => (b['status'] ?? '') == 'confirmed').length;
                final earnings = docs.fold<double>(0, (prev, b) => prev + (double.tryParse((b['amount'] ?? '0').toString()) ?? 0));
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Total bookings: $total'), Text('Confirmed: $confirmed'), Text('Earnings: \$${earnings.toStringAsFixed(2)}')]);
              },
            ),
          ]),
        );
      },
    );
  }
}




