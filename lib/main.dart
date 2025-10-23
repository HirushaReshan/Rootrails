// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rootrails/pages/business/business_auth/business_login_or_register_page.dart';

// pages
import 'package:rootrails/pages/business/business_auth/business_register_page.dart';
import 'package:rootrails/pages/business/business_pages/business_home_page.dart';
import 'package:rootrails/pages/business/business_pages/business_mylist_page.dart';
import 'package:rootrails/pages/business/business_pages/business_orders_page.dart';
import 'package:rootrails/pages/business/business_pages/business_profile_page.dart';
import 'package:rootrails/pages/user/user_auth/user_login_or_register_page.dart';
import 'package:rootrails/pages/user/user_pages/user_home_page.dart';
import 'package:rootrails/pages/park_detail_page.dart';
import 'package:rootrails/pages/settings_page.dart';
import 'package:rootrails/pages/navigator/account_type_navigate_page.dart';
import 'package:rootrails/pages/user/user_pages/user_mylist_page.dart';
import 'package:rootrails/pages/user/user_pages/user_past_travels_page.dart';
import 'package:rootrails/pages/user/user_pages/user_profile_page.dart';

import 'firebase_options.dart';
import 'themes/theme_provider.dart';

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
      // simple named routes
      routes: {
        '/': (_) => const AccountTypeNavigatePage(),
        '/user_auth_page': (_) => const UserLoginOrRegisterPage(),
        '/business_auth_page': (_) => BusinessLoginOrRegisterPage(),
        '/user_home': (_) => const UserHomePage(),
        '/business_home': (_) => const BusinessHomePage(),
        '/settings': (_) => const SettingsPage(),
        '/profile_page': (_) => const UserProfilePage(),
        '/contact_us_page': (_) => const SettingsPage(),
        '/user_mylist': (_) => const UserMyListPage(),
        '/user_past_travels': (_) => const PastTravelsPage(),
        '/business_mylist': (_) => const BusinessMyListPage(),
        '/business_orders': (_) => const BusinessOrdersPage(),
        '/business_profile': (_) => const BusinessProfilePage(),
      },

      // handle dynamic routes / routes that need arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/park_detail') {
          final args = settings.arguments;
          final parkId = args is String ? args : '';
          return MaterialPageRoute(
            builder: (context) => ParkDetailPage(parkId: parkId),
            settings: settings,
          );
        }

        // add other dynamic routes here (business_detail, driver_detail, etc.)
        return null; // fall back to routes map or unknown route
      },
    );
  }
}
