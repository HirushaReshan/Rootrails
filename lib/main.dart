// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rootrails/pages/business/business_auth/business_register_page.dart';
import 'package:rootrails/pages/business/business_pages/business_home_page.dart';
import 'package:rootrails/pages/user/user_auth/user_login_or_register_page.dart';
import 'package:rootrails/pages/user/user_pages/user_home_page.dart';
import 'firebase_options.dart';
import 'themes/theme_provider.dart';
import 'pages/navigator/account_type_navigate_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
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
      title: 'RootRails',
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: '/',
      routes: {
        '/': (_) => const AccountTypeNavigatePage(),
        '/user_auth_page': (_) => const UserLoginOrRegisterPage(),
        '/business_register_page': (_) => BusinessRegisterPage(onTap: () {}),
        '/user_home': (_) => const UserHomePage(),
        '/business_home': (_) => const BusinessHomePage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}
