import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rootrails/pages/user/user_auth/user_auth_page.dart';
import 'package:rootrails/pages/auth/auth_page.dart';
import 'package:rootrails/pages/auth/login_or_register_page.dart';
import 'package:rootrails/pages/business/business_auth/business_auth_page.dart';
import 'package:rootrails/pages/main/contact_us_page.dart';
import 'package:rootrails/pages/main/home_page.dart';
import 'package:rootrails/pages/main/profile_page.dart';
import 'package:rootrails/pages/navigator/account_type_navigate_page.dart';
import 'package:rootrails/themes/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AccountTypeNavigatePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        '/login_register_page' : (context) => const LoginOrRegisterPage(),
        '/home_page' : (context) => HomePage(),
        '/profile_page' : (context) => const ProfilePage(),
        '/contact_us_page' : (context) => const ContactUsPage(),
        '/user_auth_page' : (context) => const UserAuthPage(),
        '/business_auth_page' : (context) => const BusinessAuthPage(),
        '/selector_page' : (context) => const AccountTypeNavigatePage(),
        
        
      },
    );
  }
}