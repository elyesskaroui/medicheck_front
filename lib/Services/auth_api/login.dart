import 'dart:convert';
import 'package:flutter_application_1/Services/config.dart';
import 'package:flutter_application_1/Services/token.dart';
import 'package:http/http.dart' as http;

class LoginApi {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final String url = '${Config.baseUrl}/auth/login';
    final Map<String, String> loginData = {
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      );

      // Modifiez cette condition pour accepter aussi le code 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        // Vérifiez si le statusCode dans le body est 200
        if (responseData['statusCode'] == 200) {
          // Sauvegarder le token d'accès
          if (responseData.containsKey('accessToken')) {
            await saveToken(responseData['accessToken']);
            return {
              'success': true,
              'message': 'Login successful',
              'data': responseData,
            };
          }
        }
      }
      
      // Si on arrive ici, quelque chose s'est mal passé
      final errorResponse = json.decode(response.body);
      return {
        'success': false,
        'message': errorResponse['message'] ?? 'Login failed',
      };
      
    } catch (e) {
      print('Error details: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }
}