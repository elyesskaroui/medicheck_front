import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_application_1/models/LoginResponse.dart';
import 'package:flutter_application_1/models/SignUpResponse.dart';
import 'package:flutter_application_1/models/article.dart';
import 'package:flutter_application_1/models/chatRoom.entity.dart';
import 'package:flutter_application_1/config/app-config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(); // Dio instance for APIs
  final Dio _dioAnalysis = Dio(); // Separate Dio instance for analysis endpoint
  
  ApiService() {
    // Configure the main Dio instance
    _dio.options.baseUrl = AppConfig.BASE_URL;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Configure the separate Dio instance for the analysis endpoint
    _dioAnalysis.options.baseUrl = AppConfig.ANALYSIS_URL;
    _dioAnalysis.options.headers = {
      'Content-Type': 'application/json',
    };
    _dioAnalysis.options.connectTimeout = const Duration(seconds: 10);
    _dioAnalysis.options.receiveTimeout = const Duration(seconds: 15);
    
    // Ajouter un proxy pour aider à la connexion
    (_dioAnalysis.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.findProxy = (uri) {
        // Force toutes les connexions à être directes
        return "DIRECT";
      };
      // Ignorer les erreurs de certificat - utile si votre serveur utilise des certificats auto-signés
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
    
    print('ApiService initialized with base URL: ${AppConfig.BASE_URL}');
    print('Analysis service URL: ${AppConfig.ANALYSIS_URL}');
  }
  
  // Fixed analyzeMedicationImage method - works with your existing AppConfig
Future<String?> analyzeMedicationImage(String imageUrl) async {
  try {
    print('Analyzing medication image: $imageUrl');
    
    // Ensure the URL is properly formatted
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      imageUrl = 'https://$imageUrl';
    }
    
    print('Using formatted URL: $imageUrl');
    
    // Use localhost with port 3000 directly, since that works in Postman
    final String directUrl = "http://169.254.57.241:3000/medications/analyze";
    print('Sending request to: $directUrl');
    
    // Create request payload exactly matching what works in Postman
    final requestData = {
      'imageUrl': imageUrl
    };
    
    print('Request payload: $requestData');
    
    // Create a dedicated Dio instance for this request
    final Dio directDio = Dio();
    
    // Make the request with explicit headers
    final response = await directDio.post(
      directUrl,
      data: requestData,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    print('Response received: ${response.statusCode}');
    print('Response body: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Extract the result field from the response
      if (response.data != null && response.data['result'] != null) {
        return response.data['result'];
      } else {
        print('Missing result field in data: ${response.data}');
        return "Error: Invalid response format from server";
      }
    } else {
      print('Failed to analyze image: ${response.statusCode} ${response.statusMessage}');
      return "Error: Failed to analyze image (${response.statusCode})";
    }
  } catch (e) {
    print('Error during medication analysis: $e');
    if (e is DioException) {
      print('Request: ${e.requestOptions.uri}');
      print('Request data: ${e.requestOptions.data}');
      
      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      // Provide user-friendly error messages
      if (e.type == DioExceptionType.connectionTimeout) {
        return "Délai d'attente dépassé. Vérifiez votre connexion internet.";
      } else if (e.type == DioExceptionType.connectionError) {
        return "Erreur de connexion. Vérifiez que le serveur est accessible.";
      } else if (e.type == DioExceptionType.badResponse) {
        if (e.response?.statusCode == 404) {
          return "Erreur 404: Le service d'analyse de médicaments n'a pas été trouvé sur le serveur.";
        }
        return "Erreur serveur (${e.response?.statusCode}). L'analyse n'a pas pu être effectuée.";
      }
    }
    return "Erreur d'analyse: Le serveur a rencontré un problème. Réessayez plus tard.";
  }
}
  Future<SignUpResponse?> signUp(String name, String email, String password, [MultipartFile? profilePicture]) async {
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
        final Map<String, dynamic> responseData = Map<String, dynamic>.from(response.data);
        
        // Verify the response contains the expected structure
        if (!responseData.containsKey('message') || !responseData.containsKey('user')) {
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
      print('Failed to sign up: ${response.statusCode} ${response.statusMessage}');
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
      } else if (e.type == DioExceptionType.badResponse && e.response?.statusCode == 401) {
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
      final Map<String, dynamic> responseData = Map<String, dynamic>.from(response.data);
      
      // Save tokens in shared preferences for future use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', responseData['accessToken']);
      await prefs.setString('refreshToken', responseData['refreshToken']);
      await prefs.setString('userId', responseData['userId']);
      
      // Use the generated fromJson method
      return LoginResponse.fromJson(responseData);
    } else {
      print('Failed to login: ${response.statusCode} ${response.statusMessage}');
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
        print('Failed to send forgot password email: ${response.statusCode} ${response.statusMessage}');
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
      print('Making API call to: ${_dioAnalysis.options.baseUrl}generate with prompt: $prompt');
      
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
        print('Failed to analyze text: ${response.statusCode} ${response.statusMessage}');
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

  static void debugImageUrl(String? profilePicture) {
  if (profilePicture == null || profilePicture.isEmpty) {
    print('Empty profile picture path, using default');
    print('Default URL: ${AppConfig.DEFAULT_PROFILE_PICTURE}');
  } else {
    // Check if the profile picture already has the full URL
    if (profilePicture.startsWith('http')) {
      print('Profile picture is already a full URL: $profilePicture');
    } else {
      // Check if the profile picture starts with a slash
      String fullUrl = profilePicture.startsWith('/')
          ? AppConfig.BASE_URL + profilePicture.substring(1)
          : AppConfig.BASE_URL + profilePicture;
      print('Constructed profile picture URL: $fullUrl');
    }
  }
}

// Then modify the imageProfileLink method to handle paths better
static String imageProfileLink(String? profilePicture) {
  debugImageUrl(profilePicture);
  
  if (profilePicture == null || profilePicture.isEmpty) {
    return AppConfig.DEFAULT_PROFILE_PICTURE;
  }
  
  // Check if the profile picture already has the full URL
  if (profilePicture.startsWith('http')) {
    return profilePicture;
  }
  
  // Ensure proper path joining by handling slashes
  return profilePicture.startsWith('/')
      ? AppConfig.BASE_URL + profilePicture.substring(1)
      : AppConfig.BASE_URL + profilePicture;
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
        'auth/edit-profile/:id',
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
    final response = await http.get(Uri.parse('${AppConfig.BASE_URL}chatrooms'));

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

Future<List<Article>> fetchArticles() async {
    // The correct endpoint is /news/articles based on your NestJS controller
    final url = '${AppConfig.BASE_URL}news/articles';
    print("📡 Fetching from: $url");

    try {
      // Using Dio for consistent handling with other methods
      final response = await _dio.get('news/articles');

      if (response.statusCode == 200) {
        print("✅ Data fetched successfully");
        
        if (response.data is List) {
          List<dynamic> articlesData = response.data;
          print("📦 Fetched ${articlesData.length} articles");
          
          return articlesData.map((json) => Article.fromJson(json)).toList();
        } else {
          print("❌ Unexpected response format: ${response.data}");
          throw Exception('Unexpected response format');
        }
      } else {
        print("❌ Failed with status: ${response.statusCode}");
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      print("🔥 Error fetching articles: $e");
      
      // Retry with fallback method using http package
      try {
        print("🔄 Retrying with fallback method...");
        final httpResponse = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 10));
            
        if (httpResponse.statusCode == 200) {
          print("✅ Data fetched successfully with fallback");
          List<dynamic> data = json.decode(httpResponse.body);
          return data.map((json) => Article.fromJson(json)).toList();
        } else {
          print("❌ Fallback method also failed with status: ${httpResponse.statusCode}");
          throw Exception('Failed to load articles');
        }
      } catch (retryError) {
        print("🔥 Fallback method also failed: $retryError");
        throw Exception('Error fetching articles: $retryError');
      }
    }
  }

  // Like an article
 Future<Article> likeArticle(String articleId) async {
    // Try first with the AppConfig URL
    try {
      final response = await _dio.post('news/articles/$articleId/like');
      
      if (response.statusCode == 200) {
        return Article.fromJson(response.data);
      } else {
        throw Exception('Failed to like article');
      }
    } catch (e) {
      print("Error liking article via main API: $e");
      
      // Fallback to dedicated news service using AppConfig
      final url = '${AppConfig.BASE_URL}news/articles/$articleId/like';
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        return Article.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to like article');
      }
    }
  }

  // Dislike an article
  Future<Article> dislikeArticle(String articleId) async {
    // Try first with the AppConfig URL
    try {
      final response = await _dio.post('news/articles/$articleId/dislike');
      
      if (response.statusCode == 200) {
        return Article.fromJson(response.data);
      } else {
        throw Exception('Failed to dislike article');
      }
    } catch (e) {
      print("Error disliking article via main API: $e");
      
      // Fallback to dedicated news service using AppConfig
      final url = '${AppConfig.BASE_URL}news/articles/$articleId/dislike';
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        return Article.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to dislike article');
      }
    }
  }

  // Updated bookmark methods for ApiService class

// Get all bookmarks for current user
Future<List<Article>> getBookmarkedArticles() async {
  try {
    // Get token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    
    if (token.isEmpty) {
      print('No access token found for bookmarks request');
      return [];
    }
    
    print('Token for bookmarks: $token');
    
    // Add token to request headers
    final response = await _dio.get(
      'bookmarks',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    
    print('Bookmark response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      if (response.data is List) {
        List<dynamic> articlesData = response.data;
        print('Retrieved ${articlesData.length} bookmarked articles');
        return articlesData.map((json) => Article.fromJson(json)).toList();
      } else {
        print('Unexpected response format: ${response.data}');
        throw Exception('Unexpected response format');
      }
    } else {
      print('Failed to load bookmarked articles: ${response.statusCode}');
      throw Exception('Failed to load bookmarked articles');
    }
  } catch (e) {
    print('Error fetching bookmarked articles: $e');
    if (e is DioException) {
      print('Request: ${e.requestOptions.uri}');
      print('Headers: ${e.requestOptions.headers}');
      if (e.response != null) {
        print('Response code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
    }
    // Return empty list on error
    return [];
  }
}

// Add bookmark with improved error handling
Future<bool> addBookmark(String articleId) async {
  try {
    // Get token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    
    if (token.isEmpty) {
      print('No access token found for adding bookmark');
      return false;
    }
    
    print('Adding bookmark for articleId: $articleId');
    print('Using token: ${token.substring(0, 10)}...'); // Only log first part of token for security
    
    // Add token to request headers
    final response = await _dio.post(
      'bookmarks',
      data: {
        'articleId': articleId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    
    print('Bookmark add response: ${response.statusCode}');
    print('Bookmark add response body: ${response.data}');
    
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print('Error adding bookmark: $e');
    if (e is DioException) {
      print('Request: ${e.requestOptions.uri}');
      print('Request data: ${e.requestOptions.data}');
      print('Headers: ${e.requestOptions.headers}');
      if (e.response != null) {
        print('DioError status: ${e.response?.statusCode}');
        print('DioError message: ${e.response?.data}');
      } else {
        print('No response data available');
      }
    }
    return false;
  }
}

// Remove bookmark with improved error handling
Future<bool> removeBookmark(String articleId) async {
  try {
    // Get token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    
    if (token.isEmpty) {
      print('No access token found for removing bookmark');
      return false;
    }
    
    print('Removing bookmark for articleId: $articleId');
    
    // Add token to request headers
    final response = await _dio.delete(
      'bookmarks/$articleId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    
    print('Bookmark removal response: ${response.statusCode}');
    
    return response.statusCode == 200;
  } catch (e) {
    print('Error removing bookmark: $e');
    if (e is DioException) {
      print('Request: ${e.requestOptions.uri}');
      if (e.response != null) {
        print('DioError status: ${e.response?.statusCode}');
        print('DioError message: ${e.response?.data}');
      }
    }
    return false;
  }
}

// Check if article is bookmarked with improved error handling
Future<bool> isArticleBookmarked(String articleId) async {
  try {
    // Get token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    
    if (token.isEmpty) {
      print('No access token found for checking bookmark status');
      return false;
    }
    
    print('Checking bookmark status for articleId: $articleId');
    
    // Add token to request headers
    final response = await _dio.get(
      'bookmarks/check/$articleId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    
    print('Bookmark check response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final result = response.data['isBookmarked'] ?? false;
      print('Is bookmarked: $result');
      return result;
    } else {
      print('Failed to check bookmark status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error checking bookmark status: $e');
    if (e is DioException) {
      print('Request: ${e.requestOptions.uri}');
      if (e.response != null) {
        print('DioError status: ${e.response?.statusCode}');
        print('DioError message: ${e.response?.data}');
      }
    }
    return false;
  }
}
}