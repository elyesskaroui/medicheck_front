import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Post {
  final String id;
  final String avatarText;
  final Color avatarColor;
  final String title;
  final String content;
  final String time;
  final bool isVerified;
  final String tag; // "true", "doubt", "false"
  int likes;
  int comments;
  int shares;
  bool isFavorite;
  List<String> commentsList;

  Post({
    required this.id,
    required this.avatarText,
    required this.avatarColor,
    required this.title,
    required this.content,
    required this.time,
    required this.isVerified,
    required this.tag,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isFavorite = false,
    this.commentsList = const [],
  });

  // Pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'avatarText': avatarText,
      'avatarColor': avatarColor.value,
      'title': title,
      'content': content,
      'time': time,
      'isVerified': isVerified,
      'tag': tag,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isFavorite': isFavorite,
      'commentsList': commentsList,
    };
  }

  // Pour la désérialisation
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      avatarText: json['avatarText'] ?? 'U',
      avatarColor: Color(json['avatarColor'] ?? 0xFF9C27B0),
      title: json['title'] ?? 'Post',
      content: json['content'] ?? '',
      time: json['time'] ?? 'Maintenant',
      isVerified: json['isVerified'] ?? false,
      tag: json['tag'] ?? 'doubt',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      commentsList: json['commentsList'] != null 
          ? List<String>.from(json['commentsList']) 
          : [],
    );
  }
}

class SocialApiService {
  static const String baseUrl = 'http://192.168.0.64:3000/social';
  
  // Récupérer tous les posts
  Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['posts'] != null) {
          final List<dynamic> postsJson = data['posts'];
          return postsJson.map((postJson) => Post.fromJson(postJson)).toList();
        } else {
          throw Exception(data['message'] ?? 'Échec de la récupération des posts');
        }
      } else {
        throw Exception('Erreur réseau: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des posts: $e');
    }
  }
  
  // Récupérer un post par son ID
  Future<Post> getPostById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/$id'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['post'] != null) {
          return Post.fromJson(data['post']);
        } else {
          throw Exception(data['message'] ?? 'Post non trouvé');
        }
      } else {
        throw Exception('Erreur réseau: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du post: $e');
    }
  }
  
  // Créer un nouveau post
  Future<Post> createPost(String content, String tag) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'content': content,
          'tag': tag,
          'avatarText': 'U',
          'title': 'Mon Post'
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['post'] != null) {
          return Post.fromJson(data['post']);
        } else {
          throw Exception(data['message'] ?? 'Échec de la création du post');
        }
      } else {
        throw Exception('Erreur réseau: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du post: $e');
    }
  }
  
  // Ajouter un like à un post
  Future<Post> likePost(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$id/like'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['post'] != null) {
          return Post.fromJson(data['post']);
        } else {
          throw Exception(data['message'] ?? 'Échec de l\'ajout du like');
        }
      } else {
        throw Exception('Erreur réseau: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du like: $e');
    }
  }
  
  // Ajouter un commentaire à un post
  Future<Post> addComment(String id, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$id/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'comment': comment}),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['post'] != null) {
          return Post.fromJson(data['post']);
        } else {
          throw Exception(data['message'] ?? 'Échec de l\'ajout du commentaire');
        }
      } else {
        throw Exception('Erreur réseau: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du commentaire: $e');
    }
  }
  
  // Récupérer les commentaires d'un post
  Future<List<String>> getComments(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/$id/comments'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['comments'] != null) {
          return List<String>.from(data['comments']);
        } else {
          throw Exception(data['message'] ?? 'Échec de la récupération des commentaires');
        }
      } else {
        throw Exception('Erreur réseau: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commentaires: $e');
    }
  }
  
  // Partager un post
  Future<Post> sharePost(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$id/share'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['post'] != null) {
          return Post.fromJson(data['post']);
        } else {
          throw Exception(data['message'] ?? 'Échec du partage');
        }
      } else {
        throw Exception('Erreur réseau: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du partage: $e');
    }
  }
  
  // Marquer un post comme favori ou non
  Future<Post> toggleFavorite(String id, bool isFavorite) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/posts/$id/favorite'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isFavorite': isFavorite}),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['post'] != null) {
          return Post.fromJson(data['post']);
        } else {
          throw Exception(data['message'] ?? 'Échec de la mise à jour des favoris');
        }
      } else {
        throw Exception('Erreur réseau: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des favoris: $e');
    }
  }
  
  // Récupérer les posts favoris
  Future<List<Post>> getFavorites() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/favorites'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['posts'] != null) {
          final List<dynamic> postsJson = data['posts'];
          return postsJson.map((postJson) => Post.fromJson(postJson)).toList();
        } else {
          throw Exception(data['message'] ?? 'Échec de la récupération des favoris');
        }
      } else {
        throw Exception('Erreur réseau: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des favoris: $e');
    }
  }
  
  // Récupérer les statistiques
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur réseau: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}