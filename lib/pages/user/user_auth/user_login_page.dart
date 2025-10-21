import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_button.dart';
import 'package:rootrails/components/cards/my_textfield.dart';
import 'package:rootrails/components/cards/square_tile.dart';
import 'package:rootrails/pages/auth/forgot_password_page.dart';
import 'package:google_fonts/google_fonts.dart';

class UserLoginPage extends StatefulWidget {
  final Function()? onTap;
  const UserLoginPage({super.key, required this.onTap});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
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
      /* backgroundColor: Theme.of(context).colorScheme.background, */
      body: Container(
        //added Green gradient to the background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              const SizedBox(height: 100),

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Hello,',
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Sign',
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  //Oranged colored "in" Text
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'in!',
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),
              //Icon that on top
              Icon(Icons.group),
              Text(
                'User Account',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.white ),
              ),

              Container(
                //grey colored background decoration
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Colors.grey.shade300,
                ),

                child: Padding(
                  padding: const EdgeInsets.only(top: 10),

                  //white colored shape
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      color: Colors.white,
                    ),

                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [

                            //back button
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                      context,
                                      '/selector_page',
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0,),
                                    child: Icon(Icons.arrow_back),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "Sign in now",
                              style: GoogleFonts.poppins(
                                fontSize: 35,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 50),

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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
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
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                    ),
                                    child: Text(
                                      'Or Continue with',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.grey[400],
                                    ),
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
                                  onTap:
                                      () {} /* => AuthService().signInWithGoogle() */,
                                ),
                              ],
                            ),

                            const SizedBox(height: 50),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Not a Member?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: widget.onTap,
                                  child: Text(
                                    'Register Now',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
