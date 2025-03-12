import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/HomeScreen';
//import 'package:flutter_application_1/screens/HomeScreen.dart';
import 'package:flutter_application_1/screens/SignUp_Screen.dart';
import 'package:flutter_application_1/screens/ForgotPassword.dart';  // Assure-toi que ce fichier existe

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediCheck',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Définit la route initiale
      routes: {
        '/': (context) => HomeScreen(),
        '/signup': (context) => SignUpScreen(),
        '/forgot-password': (context) => ForgotPassword(),  // Ajoute la route ForgotPassword
      },
    );
  }
}
