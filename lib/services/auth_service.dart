import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // Removed Google Sign-In import

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn( // Removed GoogleSignIn field
  //   scopes: [
  //     'email', // Add necessary scopes here
  //   ],
  // );

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Email/Password Sign Up
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred during registration.');
    }
  }

  // Email/Password Sign In
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred during sign in.');
    }
  }

  // // Removed Google Sign In method:
  // Future<User?> signInWithGoogle() async {
  //   try {
  //     // Correct API call for modern google_sign_in package
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null; // User cancelled the sign-in

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       // Correct getter for modern google_sign_in package
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     UserCredential result = await _auth.signInWithCredential(credential);
  //     return result.user;
  //   } on FirebaseAuthException catch (e) {
  //     throw Exception(e.message);
  //   } catch (e) {
  //     throw Exception('An unknown error occurred during Google sign in.');
  //   }
  // }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred during password reset.');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    // await _googleSignIn.signOut(); // Removed Google Sign-Out call
    await _auth.signOut();
  }
}
