import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_textfield.dart';
import 'package:rootrails/components/cards/my_button.dart';

class UserLoginPage extends StatefulWidget {
  final Function()? onTap; // allows toggling to register
  const UserLoginPage({super.key, required this.onTap});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _loading = false;

  void signUserIn() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (context.mounted) Navigator.pushReplacementNamed(context, '/user_home');
    } on FirebaseAuthException catch (e) {
      _showError(e.code);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) => showDialog(
        context: context,
        builder: (_) => AlertDialog(title: Text(msg)),
      );

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MyTextfield(controller: emailController, hintText: 'Email', obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: passwordController, hintText: 'Password', obscureText: true),
            const SizedBox(height: 18),
            _loading
                ? const CircularProgressIndicator()
                : MyButton(onTap: signUserIn, text: 'Login'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Not a Member? '),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    'Register Now',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
