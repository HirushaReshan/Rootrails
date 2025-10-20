import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/my_button.dart';
import 'package:rootrails/components/my_textfield.dart';
import 'package:rootrails/components/square_tile.dart';
import 'package:rootrails/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({
    super.key,
    required this.onTap,});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controllers
  final emailController = TextEditingController();

  // password controller
  final passwordController = TextEditingController();

  //confirmed password controller

  final confirmPasswordController = TextEditingController();

  // sign user Up method
  void signUserUp() async{

    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      });

    try {
      //check if password matches and create an account
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
        );
      } else {
        //show error message Password don't match
        wrongPassWordMatchMessage();
      }

      //pop the Loading animation
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop the Loading animation
      Navigator.pop(context);
      print('Firebase Error code is : ${e.code}');
      //if user email is wrong
      if (e.code == 'invalid-email') {
        //show the error
        wrongEmailMessage();
      }
      //if password is wrong
      else if (e.code == 'invalid-credential') {
        //show the error
        wrongPassWordMessage();
      }
    }
  }

  //wrong email message popup
  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[700],
          title: Center(
            child: Text(
              'User Email not Found',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  //wrong password message popup
  void wrongPassWordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[700],
          title: Center(
            child: Text(
              'Incorrect Password',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void wrongPassWordMatchMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[700],
          title: Center(
            child: Text(
              'Passwords Don\'t macth',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        //Created a Safe Area for the Page
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                //Login page Icon
                Icon(Icons.lock, size: 100),
            
                const SizedBox(height: 25,),
            
                //Welcom Back Massege
                Text(
                  'Welcome Back to Rootrails!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
            
                const SizedBox(height: 25),
            
                //User email textField
                MyTextfield(
                  controller: emailController,
                  hintText: 'User Email : User@gmail.com',
                  obscureText: false,
                ),
            
                const SizedBox(height: 15),
            
                //Password field
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
            
                const SizedBox(height: 15,),

                //Confirm Password field
                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
            
                const SizedBox(height: 15,),
            
                //forgot password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'forgot password ?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
            
                const SizedBox(height: 25,),
            
                // Sign in Button
                MyButton(
                  onTap: signUserUp,
                  text: 'Sign Up',),
            
                const SizedBox(height: 50),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or Continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
            
                const SizedBox(height: 25,),
            
                // google login image
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      imagePath: 'lib/images/google.png',
                      onTap: () {} /* => AuthService().signInWithGoogle() */,
                      )
                    ],
                ),
            
                const SizedBox(height: 50,),
            
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already Have an Account ?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Login Now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
