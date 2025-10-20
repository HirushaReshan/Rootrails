import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/my_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPassworPageState();
}

class _ForgotPassworPageState extends State<ForgotPasswordPage> {

  final emailController = TextEditingController();

  @override
  void dispose(){
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
      .sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            content: Text(
              'Password reset link sent! Chcek your email'
            ),
          );
        }
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
              e.message.toString()
            ),
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                    Text(
                      'Enter Your Email Address to Reset',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
              
                    Text(
                      'The Password',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                    ),),
              
                    const SizedBox(height: 50,),
              
                  //User email textField
                    MyTextfield(
                      controller: emailController,
                      hintText: 'User@gmail.com',
                      obscureText: false,
                    ),
              
                    const SizedBox(height: 25,),
              
                    MaterialButton(
                      onPressed: passwordReset,
                      color: Colors.white,
                      child: Text(
                        "Reset Password",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        )
        
      ),
      
      
    );
  }
}