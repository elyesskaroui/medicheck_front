import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/SignUpResponse.dart';
import 'package:flutter_application_1/screens/ForgotPassword.dart';
import 'package:flutter_application_1/screens/SignUp_Screen.dart';
import 'package:flutter_application_1/screens/health_assistant_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/screens/news_screen.dart';
import 'package:flutter_application_1/screens/profile_page.dart';
import 'package:flutter_application_1/viewmodels/news_viewmodel.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/Screens/HomeScreen';
//import 'package:flutter_application_1/screens/HomeScreen.dart';
import 'package:flutter_application_1/screens/SignUp_Screen.dart';
import 'package:flutter_application_1/screens/ForgotPassword.dart';  // Assure-toi que ce fichier existe
import 'services/api_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize Flutter binding for async main

  // Initialize Hive
  await Hive.initFlutter();

  // Open all required Hive boxes
  await Hive.openBox('readArticlesBox');
  await Hive.openBox('userReactionsBox'); // New box for tracking like/dislike

  // Check if the user is logged in by reading SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  User? loggedUser;
  String accessToken = prefs.getString('AccessToken') ?? '';
  if (accessToken != '') {
    var apiService = ApiService();
    var result = await apiService.getUserByToken(accessToken);
    loggedUser = result;
  }

  // Run the app with the NewsViewModel provider
  runApp(
    // Add NewsViewModel at the app level
    ChangeNotifierProvider(
      create: (_) => NewsViewModel(),
      child: MyApp(loggedUser: loggedUser),
    ),
  );
}


class MyApp extends StatelessWidget {
  final User? loggedUser;

  const MyApp({super.key, required this.loggedUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediCheck',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          primary: const Color(0xFF6750A4),
          secondary: const Color(0xFF625B71),
          surface: const Color(0xFFFFFBFE),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      // Check if user is logged in and set initial route accordingly
      initialRoute: loggedUser == null ? '/' : '/main',
      routes: {
        '/': (context) => HomeScreen(),
        '/main': (context) => MainScreen(
              isDarkMode: false, // Default theme setting
              onDarkModeChanged: (value) {}, // Function to handle theme change
              loggedUser: loggedUser,
            ),
        '/signin': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPassword(),
        '/profile': (context) => ProfilePage(loggedUser: loggedUser!),
        '/news': (context) => NewsScreen(),
        '/chat': (context) => const HealthAssistantScreen(),
      },
    );
  }
}
