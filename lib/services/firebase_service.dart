import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    if (_themeMode == ThemeMode.light)
      _themeMode = ThemeMode.dark;
    else
      _themeMode = ThemeMode.light;
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
  static Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Email/password sign in
  static Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
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

  static Future<void> createGeneralUserDocument(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await firestore.collection('users').doc(uid).set(data);
  }

  static Future<void> createBusinessDocument(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await firestore.collection('businesses').doc(uid).set(data);
  }

  // Simple booking creation
  static Future<void> createBooking(Map<String, dynamic> data) async {
    await firestore.collection('bookings').add(data);
  }
}
