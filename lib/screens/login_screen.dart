import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/SignUpResponse.dart';
import 'package:flutter_application_1/screens/SignUp_Screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/screens/password_input.dart';
import 'package:flutter_application_1/screens/text_input_field.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Définition de kBodyText
const kBodyText = TextStyle(
  fontSize: 16,
  color: Colors.white,
  height: 1.5,
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
  }

  // Submit form and perform login
  void _submitForm() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please enter both email and password.', Colors.red);
      return;
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showSnackBar('Please enter a valid email address.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final loginResponse = await apiService.login(
        _emailController.text,
        _passwordController.text,
      );
      
      if (loginResponse != null) {
        // Save user data to SharedPreferences - use consistent key name
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', loginResponse.accessToken);

        try {
          var userInfo = await apiService.getUserByToken(loginResponse.accessToken);
          
          if (userInfo != null) {
            // Create user instance
            final User user = User(
              id: userInfo.id,
              name: userInfo.name,
              email: userInfo.email,
              profilePicture: userInfo.profilePicture,
            );
            
            // Navigate to main screen
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(
                    isDarkMode: false,
                    onDarkModeChanged: (value) {},
                    loggedUser: user,
                  ),
                ),
              );
            }
          } else {
            // Fallback if user info is null but login was successful
            _handleFallbackNavigation(loginResponse);
          }
        } catch (userError) {
          print('Error getting user info: $userError');
          // Handle the error by still allowing login with basic info
          _handleFallbackNavigation(loginResponse);
        }
      } else {
        _showSnackBar('Login failed. Please check your credentials.', Colors.red);
      }
    } catch (e) {
      print('Login error: $e');
      _showSnackBar('Login failed: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle navigation when user info can't be retrieved
  void _handleFallbackNavigation(dynamic loginResponse) {
    // Extract username from email
    String username = _emailController.text.split('@')[0];
    // Capitalize first letter
    String displayName = username.isNotEmpty 
        ? username[0].toUpperCase() + username.substring(1)
        : "User";
        
    final User fallbackUser = User(
      id: loginResponse.userId ?? "unknown",
      name: displayName,
      email: _emailController.text,
      profilePicture: "", 
    );
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(
            isDarkMode: false,
            onDarkModeChanged: (value) {},
            loggedUser: fallbackUser,
          ),
        ),
      );
    }
  }

  // Show Snackbar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Image de fond
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('asset/images/test.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Effet de flou pour améliorer la lisibilité
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            // Contenu principal
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  // Logo avec fond transparent
                  Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: const BoxDecoration(
                        color: Colors.white24, // Fond transparent
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Image(
                          image: AssetImage('asset/images/logo1.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Titre principal
                  const Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color.fromARGB(255, 224, 224, 224),
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Formulaire de connexion
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextInputField(
                          controller: _emailController,
                          icon: FontAwesomeIcons.envelope,
                          hint: 'Email',
                          inputType: TextInputType.emailAddress,
                          inputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        PasswordInput(
                          controller: _passwordController,
                          icon: FontAwesomeIcons.lock,
                          hint: 'Password',
                          inputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 10),
                        // Lien "Forgot Password"
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: const Text(
                            'Forgot Password',
                            style: kBodyText,
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Bouton de connexion avec animation
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: _isLoading ? 70 : 150,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _isSuccess ? Colors.green : Colors.blue,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : TextButton(
                                    onPressed: () {
                                      _submitForm();
                                    },
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                  // Lien "Créer un compte"
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: Colors.white)),
                      ),
                      child: const Text(
                        'Create New Account',
                        style: kBodyText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}