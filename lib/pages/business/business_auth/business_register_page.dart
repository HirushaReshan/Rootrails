import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rootrails/components/cards/my_button.dart';
import 'package:rootrails/components/cards/my_button2.dart';
import 'package:rootrails/components/cards/my_textfield.dart';
import 'package:rootrails/components/cards/square_tile.dart';

class BusinessRegisterPage extends StatefulWidget {
  final Function()? onTap;
  BusinessRegisterPage({super.key, required this.onTap});

  @override
  State<BusinessRegisterPage> createState() => _BusinessRegisterPageState();
}

class _BusinessRegisterPageState extends State<BusinessRegisterPage> {
  //text editing controllers
  final emailController = TextEditingController();

  // password controller
  final passwordController = TextEditingController();

  //confirmed password controller
  final confirmPasswordController = TextEditingController();

  //Business Name controller
  final businessNameController = TextEditingController();

  //Business description controller
  final businessDescriptionController = TextEditingController();

  //Price controller
  final priceController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    businessNameController.dispose();
    businessDescriptionController.dispose();
    priceController.dispose();

    super.dispose();
  }

  // sign user Up method
  void signUserUp() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      //check if password matches and create an account
      if (passwordController.text == confirmPasswordController.text) {
        //create user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        //add business details on the server
        addUserDetails(
          businessNameController.text.trim(),
          businessDescriptionController.text.trim(),
          int.parse(priceController.text.trim()),
          emailController.text.trim(),
          passwordController.text.trim(),
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

  Future addUserDetails(
    String businessName,
    String businessDescription,
    int price,
    String email,
    String password,
  ) async {
    // Format the business name to be a valid Firestore ID (no spaces, lowercase)
    String formattedBusinessName = businessName
        .trim()
        .replaceAll(' ', '_')
        .toLowerCase();

    await FirebaseFirestore.instance
        .collection('Business_Users')
        .doc(
          formattedBusinessName,
        ) 
        .set({
          'Business name': businessName,
          'Business description': businessDescription,
          'Business price': price,
          'email': email,
          'password': password,
          'createdAt': FieldValue.serverTimestamp(), // adds timestamp
        });
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
                  'Business Register Page',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                //businesName textField
                MyTextfield(
                  controller: businessNameController,
                  hintText: 'Business Name',
                  obscureText: false,
                ),

                const SizedBox(height: 15),

                //Business Description textField
                MyTextfield(
                  controller: businessDescriptionController,
                  hintText: 'Enter a small Description',
                  obscureText: false,
                ),

                const SizedBox(height: 15),

                //Business Price textField
                MyTextfield(
                  controller: priceController,
                  hintText: 'Enter the price for a Ride LKR',
                  obscureText: false,
                ),

                const SizedBox(height: 15),

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

                //Confirm Password field
                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 15),

                const SizedBox(height: 25),

                // Sign in Button
                MyButton(onTap: signUserUp, text: 'Sign Up'),

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

                const SizedBox(height: 50,),


                //go back button
                MyButton2(onTap: (){
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/selector_page');
                }, text: 'Go Back'),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
