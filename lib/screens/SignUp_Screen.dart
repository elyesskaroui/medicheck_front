import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/password_input.dart';
import 'package:flutter_application_1/screens/text_input_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart'; // Add shared_preferences for saving data locally

const kBodyText = TextStyle(
  fontSize: 16,
  color: Colors.white,
  height: 1.5,
);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  File? _profilePicture;

  final ImagePicker _picker = ImagePicker();

  // Pick image function
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profilePicture = File(pickedFile.path);
        });
        print('Image selected: ${pickedFile.path}');
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(
      String name, String email, String profilePicture) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('profilePicture', profilePicture);
  }

  // Submit the form and make the API call
  void _submitForm() async {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showSnackBar('Please enter a valid email address.', Colors.red);
      return;
    }

    // Validate input fields first
    if (_firstNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _profilePicture == null) {
      _showSnackBar('Please fill in all fields.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();

      // Handle file upload
      MultipartFile? profilePictureFile;
      if (_profilePicture != null) {
        try {
          // When preparing your profile picture in SignUp_Screen.dart:
          profilePictureFile = await MultipartFile.fromFile(
            _profilePicture!.path,
            filename: _profilePicture!.path.split('/').last,
            contentType:
                MediaType.parse('image/jpeg'), // Explicitly set content type
          );
          print(
              'Profile picture prepared for upload: ${profilePictureFile.filename}');
        } catch (e) {
          print('Error preparing profile picture: $e');
          // Continue with signup even if image preparation fails
        }
      }
      print("signup ...");
      final signUpResponse = await apiService.signUp(
        _firstNameController.text,
        _emailController.text,
        _passwordController.text,
        profilePictureFile,
      );
      print("signup Done");

      if (signUpResponse != null) {
        setState(() {
          _isSuccess = true;
        });
        _showSnackBar('Sign Up Successful!', Colors.green);

        // Save the user data locally after successful sign-up
        await _saveUserData(
          _firstNameController.text,
          _emailController.text,
          _profilePicture != null ? _profilePicture!.path : '',
        );

        // Wait briefly to show success state
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/signin');
      } else {
        _showSnackBar('Sign Up failed. Please try again.', Colors.red);
      }
    } catch (e) {
      print('Error during signup: $e');
      _showSnackBar('An error occurred: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show snackbar with message
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
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'asset/images/test.jpg'), // Replace with your background image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Overlay for better readability
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            // Main content
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  // Main Title
                  const Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color.fromARGB(255, 224, 224, 224),
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Profile Picture
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: _profilePicture != null
                            ? FileImage(_profilePicture!)
                            : null,
                        child: _profilePicture == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sign Up Form
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 20),
                        TextInputField(
                          controller: _firstNameController,
                          icon: FontAwesomeIcons.user,
                          hint: 'Prénom',
                          inputType: TextInputType.name,
                          inputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 30),
                        // Submit Button with animation
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
                                    onPressed: _submitForm,
                                    child: const Text(
                                      'Sign Up',
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
                  const SizedBox(height: 20),
                  // Link to Login page
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.transparent)),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: kBodyText,
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Login',
                              style: kBodyText.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
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
