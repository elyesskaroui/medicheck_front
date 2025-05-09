import 'dart:convert';
import 'package:flutter_application_1/Services/config.dart';
import 'package:http/http.dart' as http;

class SignupApi {
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String prenom,
    required String email,
    required String password,
  }) async {
    final String url = '${Config.baseUrl}/auth/signup';
    final Map<String, String> signupData = {
      'name': name,
      'prenom': prenom,
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signupData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return {
          'success': true,
          'message': responseBody['message'] ?? 'User created successfully',
          'data': responseBody,
        };
      } else {
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'message': errorResponse['message'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }
}
