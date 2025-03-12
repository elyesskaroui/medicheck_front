import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_application_1/models/LoginResponse.dart';
import 'package:flutter_application_1/models/SignUpResponse.dart';
import 'package:flutter_application_1/models/chatRoom.entity.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(); // Dio instance for localhost:3000
  final Dio _dioAnalysis = Dio(); // Separate Dio instance for analysis endpoint
  static const String BASE_URL = "http://172.16.1.63:3005/"; // For other APIs

  // Modifié pour utiliser 127.0.0.1 qui devrait fonctionner dans la plupart des cas
  static const String BASE_URL_ANALYSIS = "http:// 172.16.1.63:9000/";
  ApiService() {
    // Configure the main Dio instance for localhost:3000
    _dio.options.baseUrl = BASE_URL;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Configure the separate Dio instance for the analysis endpoint
    _dioAnalysis.options.baseUrl = BASE_URL_ANALYSIS;
    _dioAnalysis.options.headers = {
      'Content-Type': 'application/json',
    };
    _dioAnalysis.options.connectTimeout = const Duration(seconds: 10);
    _dioAnalysis.options.receiveTimeout = const Duration(seconds: 15);

    // Ajouter un proxy pour aider à la connexion
    (_dioAnalysis.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
        () {
      final client = HttpClient();
      client.findProxy = (uri) {
        // Force toutes les connexions à être directes
        return "DIRECT";
      };
      // Ignorer les erreurs de certificat - utile si votre serveur utilise des certificats auto-signés
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<SignUpResponse?> signUp(String name, String email, String password,
      [MultipartFile? profilePicture]) async {
    try {
      print('Starting signup process for email: $email');

      // Create form data with proper encoding for multipart request
      final FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        if (profilePicture != null) 'profilePicture': profilePicture,
      });

      print('Sending signup request with data: ${formData.fields}');
      print('File attached: ${profilePicture != null ? 'Yes' : 'No'}');

      // Ensure proper headers are set for multipart form data
      final response = await _dio.post(
        'auth/signup',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
          // Increase upload timeout for image upload
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print('Signup response status: ${response.statusCode}');
      print('Signup response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          // Convert response data to a proper Map<String, dynamic>
          final Map<String, dynamic> responseData =
              Map<String, dynamic>.from(response.data);

          // Verify the response contains the expected structure
          if (!responseData.containsKey('message') ||
              !responseData.containsKey('user')) {
            print('Invalid response format: missing required fields');
            return null;
          }

          // Use the generated fromJson method
          return SignUpResponse.fromJson(responseData);
        } catch (parseError) {
          print('Error parsing signup response: $parseError');
          return null;
        }
      } else {
        print(
            'Failed to sign up: ${response.statusCode} ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Error during signup: $e');
      if (e is DioException) {
        print('Request: ${e.requestOptions.uri}');
        if (e.response != null) {
          print('Response code: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
        print('Error type: ${e.type}');

        // Provide more specific error handling
        if (e.type == DioExceptionType.connectionTimeout) {
          print('Connection timeout - check server availability');
        } else if (e.type == DioExceptionType.badResponse &&
            e.response?.statusCode == 401) {
          print('Unauthorized - check authentication requirements');
        }
      }
      return null;
    }
  }

  // Login method
  Future<LoginResponse?> login(String email, String password) async {
    try {
      print('Attempting login for email: $email');
      final response = await _dio.post(
        'auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ensure all required fields are present in the response
        if (response.data['accessToken'] == null ||
            response.data['refreshToken'] == null ||
            response.data['userId'] == null) {
          print('Invalid response format: missing required fields');
          return null;
        }

        // Convert response data to a proper Map<String, dynamic>
        final Map<String, dynamic> responseData =
            Map<String, dynamic>.from(response.data);

        // Save tokens in shared preferences for future use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', responseData['accessToken']);
        await prefs.setString('refreshToken', responseData['refreshToken']);
        await prefs.setString('userId', responseData['userId']);

        // Use the generated fromJson method
        return LoginResponse.fromJson(responseData);
      } else {
        print(
            'Failed to login: ${response.statusCode} ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      if (e is DioException) {
        print('Request: ${e.requestOptions.uri}');
        if (e.response != null) {
          print('Response code: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
        print('Error type: ${e.type}');
      }
      return null;
    }
  }

  // Forgot password method
  Future<void> forgotPassword(String email) async {
    try {
      print('Sending forgot password request for email: $email');
      final response = await _dio.post(
        'auth/forgot-password',
        data: {
          'email': email,
        },
      );

      print('Forgot password response status: ${response.statusCode}');
      print('Forgot password response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Forgot password email sent successfully.');
      } else {
        print(
            'Failed to send forgot password email: ${response.statusCode} ${response.statusMessage}');
        throw Exception('Failed to send forgot password email');
      }
    } catch (e) {
      print('Error during forgot password request: $e');
      throw Exception('Error during forgot password request');
    }
  }

  // Analyze method
  Future<String?> analyzeText(String prompt) async {
    try {
      print(
          'Making API call to: ${_dioAnalysis.options.baseUrl}generate with prompt: $prompt');

      // S'assurer que les données sont correctement formatées
      final Map<String, dynamic> requestData = {
        'prompt': prompt,
      };

      print('Request data: $requestData');

      final response = await _dioAnalysis.post(
        'generate', // Endpoint for analysis
        data: requestData,
      );

      print('Response received: ${response.statusCode}');
      print('Response body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data['response'] != null) {
          return response.data['response'];
        } else {
          print('Missing response field in data: ${response.data}');
          return "Error: Invalid response format from server";
        }
      } else {
        print(
            'Failed to analyze text: ${response.statusCode} ${response.statusMessage}');
        throw Exception('Failed to analyze text');
      }
    } catch (e) {
      print('Error during analyze request: $e');
      if (e is DioException) {
        print('Request: ${e.requestOptions.uri}');
        print('Response: ${e.response?.data}');
        print('Error type: ${e.type}');

        // Messages d'erreur plus spécifiques selon le type d'erreur
        if (e.type == DioExceptionType.connectionTimeout) {
          return "Connection timeout. Please check your internet connection.";
        } else if (e.type == DioExceptionType.connectionError) {
          return "Connection error. Please make sure the server is running and accessible.";
        } else if (e.type == DioExceptionType.badResponse) {
          return "Server returned error: ${e.response?.statusCode} ${e.response?.statusMessage}";
        }
      }
      return "Error: Failed to connect to the analysis server. Please try again later.";
    }
  }

  static String imageProfileLink(String? profilePicture) {
    if (profilePicture != null) {
      return BASE_URL + profilePicture;
    }
    return '${BASE_URL}uploads/profiles/default.png';
  }

  // Edit profile method
  Future<Map<String, dynamic>> editProfile({
    required String name,
    required String email,
    String? oldPassword,
    String? newPassword,
    MultipartFile? profilePicture,
    required String token,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        if (oldPassword != null) 'oldPassword': oldPassword,
        if (newPassword != null) 'newPassword': newPassword,
        if (profilePicture != null) 'profilePicture': profilePicture,
      });

      final response = await _dio.put(
        '${BASE_URL}auth/edit-profile/:id',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Error updating profile');
    }
  }

  Future<List<ChatRoom>> getChatRooms() async {
    final response = await http.get(Uri.parse('$BASE_URL/chatrooms'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChatRoom.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat rooms');
    }
  }

  Future<User?> getUserByToken(String token) async {
    try {
      print('Verifying token and getting user info...');
      final response = await _dio.post(
        'auth/verify-token',
        data: {
          'token': token,
        },
      );

      print('User verification response status: ${response.statusCode}');
      print('User verification response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null) {
          print('Server returned empty response for token verification');
          return null;
        }

        try {
          // Make sure the response is a Map<String, dynamic>
          final userData = response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : null;

          if (userData == null) {
            print('Invalid user data format');
            return null;
          }

          // Create User object from the response
          return User.fromJson(userData);
        } catch (parseError) {
          print('Error parsing user data: $parseError');
          return null;
        }
      } else {
        print('Token verification failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during token verification: $e');
      if (e is DioException) {
        print('Request: ${e.requestOptions.uri}');
        if (e.response != null) {
          print('Response code: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
      }
      return null;
    }
  }
}
