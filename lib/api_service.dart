/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'post.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.64:3000/social'; // Remplacez par votre URL

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['posts'] as List).map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Échec du chargement des posts: ${response.statusCode}');
    }
  }

  Future<Post> createPost({
    required String content,
    required String tag,
    String title = 'Mon Post',
    String avatarText = 'U',
    int avatarColor = 0xFF9C27B0,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'content': content,
        'tag': tag,
        'title': title,
        'avatarText': avatarText,
        'avatarColor': avatarColor,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body)['post']);
    } else {
      throw Exception('Échec de la création: ${response.statusCode}');
    }
  }

  Future<Post> likePost(String id) async {
    final response = await http.post(Uri.parse('$baseUrl/posts/$id/like'));
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body)['post']);
    } else {
      throw Exception('Échec du like: ${response.statusCode}');
    }
  }

  Future<Post> addComment(String id, String comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$id/comments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'comment': comment}),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body)['post']);
    } else {
      throw Exception('Échec de l\'ajout de commentaire: ${response.statusCode}');
    }
  }

  Future<List<String>> getPostComments(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id/comments'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['comments'] as List).map((c) => c.toString()).toList();
    } else {
      throw Exception('Échec du chargement des commentaires: ${response.statusCode}');
    }
  }

  Future<Post> sharePost(String id) async {
    final response = await http.post(Uri.parse('$baseUrl/posts/$id/share'));
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body)['post']);
    } else {
      throw Exception('Échec du partage: ${response.statusCode}');
    }
  }

  Future<Post> toggleFavorite(String id, bool isFavorite) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id/favorite'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isFavorite': isFavorite}),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body)['post']);
    } else {
      throw Exception('Échec de la mise à jour des favoris: ${response.statusCode}');
    }
  }

  Future<List<Post>> getFavorites() async {
    final response = await http.get(Uri.parse('$baseUrl/favorites'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['posts'] as List).map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Échec du chargement des favoris: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(Uri.parse('$baseUrl/stats'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec du chargement des stats: ${response.statusCode}');
    }
  }
}*/