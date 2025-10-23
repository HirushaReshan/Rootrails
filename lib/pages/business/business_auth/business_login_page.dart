import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Assuming your custom components are correctly implemented
import 'package:rootrails/components/cards/my_button.dart';
import 'package:rootrails/components/cards/my_textfield.dart';

class BusinessLoginPage extends StatefulWidget {
  final VoidCallback onTap; // toggle to register page
  const BusinessLoginPage({super.key, required this.onTap});

  @override
  State<BusinessLoginPage> createState() => _BusinessLoginPageState();
}

class _BusinessLoginPageState extends State<BusinessLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _loading = false;

  void loginBusiness() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _show('Please enter email and password.');
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check context.mounted before any navigation or dialog to avoid errors
      if (!mounted) return;

      // Successfully logged in. Navigate to home page.
      // NOTE: For a persistent login, using Navigator.pushReplacementNamed
      // here might be bypassed by BusinessAuthPage's StreamBuilder.
      // It's generally better to let the BusinessAuthPage handle the route
      // change once the user state changes.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _show('Error: ${e.message}');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _show(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTextfield(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 18),
            // The main login button
            _loading
                ? const CircularProgressIndicator()
                : MyButton(onTap: loginBusiness, text: 'Login'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don’t have an account? '),
                // This InkWell calls onTap (the toggle function) to go to the Register page.
                InkWell(
                  onTap: widget.onTap,
                  child: const Text(
                    'Register Now',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
