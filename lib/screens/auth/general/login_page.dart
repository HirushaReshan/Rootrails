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
      await FirebaseService.signInWithEmail(
        _email.text.trim(),
        _password.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
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
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  FirebaseService.sendPasswordReset(_email.text.trim()),
              child: const Text('Forgot password?'),
            ),
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const UserHomePage()),
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/google.png', width: 24, height: 24),
                  const SizedBox(width: 8),
                  const Text('Sign in with Google'),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Not a member?'),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GeneralRegister()),
                  ),
                  child: const Text('Register now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
