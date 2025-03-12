import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/SignUpResponse.dart';
import 'package:flutter_application_1/screens/ForgotPassword.dart';
import 'package:flutter_application_1/screens/HomeScreen.dart';
import 'package:flutter_application_1/screens/SignUp_Screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/screens/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/api_service.dart'; // Import MainScreen

void main() async {
  // Ensure binding is initialized before calling SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // Check if the user is logged in by reading SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  User? loggedUser;
  String accessToken = prefs.getString('AccessToken') ?? '';
  if (accessToken != '') {
    var apiService = ApiService();
    var result = await apiService.getUserByToken(accessToken);
    loggedUser = result;
  }

  // bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Run the app and pass the login status to MyApp
  runApp(MyApp(loggedUser: loggedUser));
}

class MyApp extends StatelessWidget {
  final User? loggedUser;

  const MyApp({super.key, required this.loggedUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediCheck',
      theme: ThemeData(primarySwatch: Colors.blue),
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
      },
    );
  }
}
