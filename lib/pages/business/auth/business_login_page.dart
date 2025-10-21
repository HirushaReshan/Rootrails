import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_button.dart';
import 'package:rootrails/components/cards/my_button2.dart';
import 'package:rootrails/components/cards/my_textfield.dart';
import 'package:rootrails/components/cards/square_tile.dart';
import 'package:rootrails/pages/auth/forgot_password_page.dart';

class BusinessLoginPage extends StatefulWidget {
  final Function()? onTap;
  BusinessLoginPage({super.key, required this.onTap});

  @override
  State<BusinessLoginPage> createState() => _BusinessLoginPageState();
}

class _BusinessLoginPageState extends State<BusinessLoginPage> {
  //text editing controllers
  final emailController = TextEditingController();

  // password controller
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

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

  //wrong email message popup
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        //Created a Safe Area for the Page
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Container(
                        width: 50,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),
                    //Login page Icon
                    Icon(Icons.lock, size: 100),
                
                    const SizedBox(height: 25),
                
                    //Welcom Back Massege
                    Text(
                      'Welcome Back to Rootrails!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                
                    const SizedBox(height: 25),
                
                    Text(
                      'Business Login Page',
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
                
                    const SizedBox(height: 15),
                
                    //forgot password
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ForgotPasswordPage();
                                  },
                                ),
                              );
                            },
                            child: Text(
                              'forgot password ?',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    const SizedBox(height: 25),
                
                    // Sign in Button
                    MyButton(onTap: signUserIn, text: 'Sign In'),
                
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
                
                    const SizedBox(height: 25),
                
                    // google login image
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SquareTile(
                          imagePath: 'lib/images/google.png',
                          onTap: () {} /* => AuthService().signInWithGoogle() */,
                        ),
                      ],
                    ),
                
                    const SizedBox(height: 50),
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Not a Member?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            'Register Now',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50,),
                
                
                    //go back button
                    MyButton2(onTap: (){
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/selector_page');
                    }, text: 'Go Back'),
                
                    const SizedBox(height: 50),
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
