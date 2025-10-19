import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Must use the named constructor in v7.0.0+
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email', // default scope
    ],
  );

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1️⃣ Start the interactive sign-in process
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

      // If the user cancels the sign-in flow
      if (gUser == null) return null;

      // 2️⃣ Obtain the authentication details
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // 3️⃣ Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // 4️⃣ Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('General error during Google Sign-In: $e');
      return null;
    }
  }

  // Optional: sign out from both Firebase & Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
