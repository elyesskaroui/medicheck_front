import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Services/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
//import social 'dart:convert';
import 'package:flutter/services.dart';

// URL de base pour l'API
const String baseUrl = '${Config.baseUrl}';
// ID utilisateur temporaire (à remplacer par un système d'authentification)
const String userId = 'user123';

// Délai d'attente pour les requêtes HTTP (en secondes)
const int apiTimeoutSeconds = 10;

void main() {
  // Forcer l'orientation portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Configurer la transparence de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const Social());
}

class Social extends StatelessWidget {
  const Social({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfoSanté',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4285F4),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4285F4),
          secondary: Color(0xFF34A853),
          tertiary: Color(0xFFEA4335),
          surface: Colors.white,
          background: Color(0xFFF8F9FA),
        ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF4285F4),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF202124),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          shadowColor: Colors.black26,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          shadowColor: Colors.black12,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4285F4),
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey.shade100,
          selectedColor: const Color(0xFF4285F4).withOpacity(0.15),
          labelStyle: const TextStyle(fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: const HomePage(),
    );
  }
}

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
  List<Comment> commentsList;

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

  // Pour la désérialisation depuis l'API
  factory Post.fromJson(Map<String, dynamic> json) {
    List<Comment> commentsFromJson = [];
    if (json['commentsList'] != null) {
      commentsFromJson = (json['commentsList'] as List)
          .map((comment) => Comment.fromJson(comment))
          .toList();
    }

    return Post(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      avatarText: json['avatarText'] ?? 'U',
      avatarColor: json['avatarColor'] != null ? Color(json['avatarColor']) : Colors.blue,
      title: json['title'] ?? 'Titre inconnu',
      content: json['content'] ?? 'Contenu indisponible',
      time: json['time'] ?? 'Récemment',
      isVerified: json['isVerified'] ?? false,
      tag: json['tag'] ?? 'doubt',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      commentsList: commentsFromJson,
    );
  }

  // Pour la sérialisation vers l'API
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
    };
  }
}

class Comment {
  final String id;
  final String content;
  final String username;
  final String timeAgo;
  final String avatarText;
  final Color avatarColor;
  int likes;

  Comment({
    required this.id,
    required this.content,
    required this.username,
    required this.timeAgo,
    required this.avatarText,
    required this.avatarColor,
    this.likes = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final DateTime createdAt = json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now();
    final timeAgo = _getTimeAgo(createdAt);
    
    // Déterminer la première lettre pour l'avatar et générer une couleur aléatoire
    final String username = json['username'] ?? 'Utilisateur';
    final String avatarText = username.isNotEmpty ? username[0].toUpperCase() : 'U';
    
    // Utiliser la valeur de couleur fournie ou générer une valeur par défaut
    final Color avatarColor = json['avatarColor'] != null 
        ? Color(json['avatarColor']) 
        : Colors.primaries[avatarText.codeUnitAt(0) % Colors.primaries.length];

    return Comment(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? '',
      username: username,
      timeAgo: timeAgo,
      avatarText: avatarText,
      avatarColor: avatarColor,
      likes: json['likes'] ?? 0,
    );
  }

  static String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} semaine(s)';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} jour(s)';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure(s)';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute(s)';
    } else {
      return 'À l\'instant';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'username': username,
      'avatarText': avatarText,
      'avatarColor': avatarColor.value,
      'likes': likes,
    };
  }
}

// Widget pour afficher un commentaire individuel
class CommentWidget extends StatelessWidget {
  final Comment comment;

  const CommentWidget({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: comment.avatarColor,
            child: Text(
              comment.avatarText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            radius: 18,
          ),
          const SizedBox(width: 12),
          // Contenu du commentaire
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                // Actions (like, réponse)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Logique pour liker un commentaire
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.thumb_up_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            comment.likes > 0 ? '${comment.likes}' : 'J\'aime',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        // Logique pour répondre à un commentaire
                      },
                      child: Text(
                        'Répondre',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ApiService {
  // Méthode générique pour effectuer des requêtes GET avec gestion d'erreurs
  static Future<dynamic> _getRequest(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(uri).timeout(
        Duration(seconds: apiTimeoutSeconds),
        onTimeout: () {
          throw Exception('Délai d\'attente dépassé');
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la requête GET à $endpoint: $e');
      return null;
    }
  }


  static Future<bool> deletePost(String postId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/publication'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'postId': postId}),
    ).timeout(Duration(seconds: apiTimeoutSeconds));

    return response.statusCode == 200;
  } catch (e) {
    debugPrint('Erreur lors de la suppression du post: $e');
    return false;
  }
}
  
  // Méthode générique pour effectuer des requêtes POST avec gestion d'erreurs
  static Future<dynamic> _postRequest(String endpoint, {Map<String, dynamic>? body, Map<String, String>? queryParams}) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        Duration(seconds: apiTimeoutSeconds),
        onTimeout: () {
          throw Exception('Délai d\'attente dépassé');
        },
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return {'success': true};
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la requête POST à $endpoint: $e');
      return null;
    }
  }

  // Récupérer toutes les publications
  static Future<List<Post>> getPosts() async {
    try {
      final jsonData = await _getRequest('publication', queryParams: {'info': 'getPosts'});
      
      if (jsonData != null && jsonData is List) {
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else {
        // Si l'API renvoie un format inattendu ou est indisponible
        return _getDefaultPosts();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des publications: $e');
      // En cas d'erreur, renvoyer des données simulées
      return _getDefaultPosts();
    }
  }
  
  // Créer une nouvelle publication
  static Future<Post> createPost(Post post) async {
    try {
      final jsonData = await _postRequest(
        'publication',
        queryParams: {'info': 'createPost'},
        body: post.toJson(),
      );
      
      if (jsonData != null) {
        return Post.fromJson(jsonData);
      } else {
        // Si l'API est indisponible, simplement retourner le post original
        return post;
      }
    } catch (e) {
      debugPrint('Erreur lors de la création de la publication: $e');
      // Retourner le post original en cas d'erreur
      return post;
    }
  }
  
  // Ajouter un like à une publication
  static Future<bool> likePost(String postId) async {
    try {
      final result = await _postRequest(
        'publication',
        queryParams: {'info': 'likePost', 'postId': postId},
      );
      
      return result != null;
    } catch (e) {
      debugPrint('Erreur lors du like: $e');
      return false;
    }
  }
  
  // Partager une publication
  static Future<bool> sharePost(String postId) async {
    try {
      final result = await _postRequest(
        'publication',
        queryParams: {'info': 'sharePost', 'postId': postId},
      );
      
      return result != null;
    } catch (e) {
      debugPrint('Erreur lors du partage: $e');
      return false;
    }
  }
  
  // Ajouter un commentaire
  static Future<Comment?> addComment(String postId, String content) async {
    try {
      final jsonData = await _postRequest(
        'commentaire',  // Corrigé de "commaintre" à "commentaire"
        queryParams: {'info': 'addComment', 'postId': postId},
        body: {
          'content': content,
          'userId': userId,
          'username': 'Utilisateur',
        },
      );
      
      if (jsonData != null) {
        return Comment.fromJson(jsonData);
      } else {
        // En cas d'erreur ou d'indisponibilité de l'API, créer un commentaire local
        return Comment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: content,
          username: 'Utilisateur',
          timeAgo: 'À l\'instant',
          avatarText: 'U',
          avatarColor: Colors.blue,
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout du commentaire: $e');
      // En cas d'erreur, simuler un commentaire local
      return Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        username: 'Utilisateur',
        timeAgo: 'À l\'instant',
        avatarText: 'U',
        avatarColor: Colors.blue,
      );
    }
  }
  
  // Récupérer les commentaires d'une publication
  static Future<List<Comment>> getPostComments(String postId) async {
    try {
      final jsonData = await _getRequest(
        'commentaire',  // Corrigé de "commaintre" à "commentaire"
        queryParams: {'info': 'getComments', 'postId': postId},
      );
      
      if (jsonData != null && jsonData is List) {
        return jsonData.map((json) => Comment.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des commentaires: $e');
      return [];
    }
  }
  
  // Ajouter/supprimer des favoris
  static Future<bool> toggleFavorite(String postId) async {
    try {
      final jsonData = await _postRequest(
        'favorite',
        queryParams: {'info': 'toggleFavorite'},
        body: {
          'userId': userId,
          'postId': postId
        },
      );
      
      if (jsonData != null && jsonData['isFavorite'] != null) {
        return jsonData['isFavorite'];
      } else {
        // En cas d'indisponibilité de l'API, inverser l'état actuel
        return true; // Par défaut on considère que ça a fonctionné
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des favoris: $e');
      return false;
    }
  }
  
  // Récupérer les publications favorites
  static Future<List<Post>> getFavorites() async {
    try {
      final jsonData = await _getRequest(
        'favorite',
        queryParams: {'info': 'getFavorites', 'userId': userId},
      );
      
      if (jsonData != null && jsonData is List) {
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des favoris: $e');
      return [];
    }
  }

  // Données par défaut en cas d'erreur de connexion à l'API
  static List<Post> _getDefaultPosts() {
    return [
      Post(
        id: '1',
        avatarText: 'N',
        avatarColor: const Color(0xFFE91E63),
        title: 'Neurologie Info',
        content: '🧠Les maux de tête ne sont pas toujours le signe d\'une tumeur cérébrale. 90% des céphalées sont des migraines ou céphalées de tension.',
        time: 'Il y a 2 heures',
        isVerified: true,
        tag: 'true',
        likes: 243,
        comments: 32,
        shares: 19,
        commentsList: [
          Comment(
            id: '101',
            content: 'Merci pour cette précision, cela rassure!',
            username: 'Julien',
            timeAgo: 'Il y a 1 heure',
            avatarText: 'J',
            avatarColor: Colors.teal,
            likes: 8,
          ),
          Comment(
            id: '102',
            content: 'Quels sont les signes qui devraient nous alerter dans ce cas?',
            username: 'Marie',
            timeAgo: 'Il y a 45 minutes',
            avatarText: 'M',
            avatarColor: Colors.purple,
            likes: 3,
          ),
        ],
      ),
      Post(
        id: '2',
        avatarText: 'S',
        avatarColor: const Color(0xFFFF5722),
        title: 'SantéNaturelle',
        content: '🍋 Boire du jus de citron à jeun peut aider à guérir plus de 10 maladies,🦴 dont l’arthrite et 🍽️ les troubles digestifs.💧 Un petit geste naturel pour un grand bien-être !',
        time: 'Il y a 2 heures',
        isVerified: true,
        tag: 'doubt',
        likes: 127,
        comments: 80,
        shares: 27,
        commentsList: [
          Comment(
            id: '201',
            content: '⚠️Attention aux affirmations exagérées.🍋 Le citron a des bienfaits, mais ne guérit pas tout !!',
            username: 'Dr. Martin',
            timeAgo: 'Il y a 1 heure',
            avatarText: 'D',
            avatarColor: Colors.blue,
            likes: 42,
          ),
        ],
      ),
      Post(
        id: '3',
        avatarText: 'V',
        avatarColor: const Color(0xFF2196F3),
        title: 'VaccinInfo',
        content: '❌🧪💉Les vaccins contiennent des micropuces qui permettent de suivre les personnes et de contrôler leur comportement.',
        time: 'Il y a 3 heures',
        isVerified: true,
        tag: 'false',
        likes: 12,
        comments: 156,
        shares: 41,
        commentsList: [
          Comment(
            id: '301',
            content: 'Cette information est complètement fausse et a été démentie par de nombreux scientifiques.',
            username: 'Institut Santé',
            timeAgo: 'Il y a 2 heures',
            avatarText: 'I',
            avatarColor: Colors.green,
            likes: 89,
          ),
        ],
      ),
      Post(
        id: '4',
        avatarText: 'A',
        avatarColor: const Color(0xFF9C27B0),
        title: 'Alimentation Santé',
        content: '⚠️ Les œufs 🥚 augmentent le cholestérol sanguin 🩸 et sont mauvais pour la santé cardiovasculaire .',
        time: 'Il y a 5 heures',
        isVerified: true,
        tag: 'false',
        likes: 198,
        comments: 45,
        shares: 23,
      ),
      Post(
        id: '5',
        avatarText: 'P',
        avatarColor: const Color(0xFF009688),
        title: 'PharmaSanté',
        content: '❌ Les antibiotiques🧪 sont efficaces contre la grippe 🤒 et le rhume 🤧.',
        time: 'Il y a 12 heures',
        isVerified: true,
        tag: 'false',
        likes: 321,
        comments: 73,
        shares: 112,
      ),
    ];
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Post> posts = [];
  List<Post> favoritePosts = [];
  final TextEditingController _postController = TextEditingController();
  String? selectedTag;
  bool isLoading = true;
  bool isRefreshing = false;
  bool isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Si on passe à l'onglet favoris, mettre à jour la liste
      if (_tabController.index == 1) {
        _updateFavoritesList();
      }
    });
    _loadInitialData();
  }
Future<void> _loadInitialData() async {
  setState(() {
    isLoading = true;
  });

  // Charger d'abord les posts statiques
  List<Post> staticPosts = ApiService._getDefaultPosts();
  
  try {
    // Tenter de charger les publications depuis l'API
    final fetchedPosts = await ApiService.getPosts();
    
    // Filtrer pour éviter les doublons (basés sur l'ID)
    List<String> staticPostIds = staticPosts.map((post) => post.id).toList();
    List<Post> uniqueFetchedPosts = fetchedPosts
        .where((post) => !staticPostIds.contains(post.id))
        .toList();
    
    // Combiner les posts statiques et les posts récupérés de l'API
    List<Post> allPosts = [...staticPosts, ...uniqueFetchedPosts];
    
    // Si les publications ont été chargées avec succès
    if (allPosts.isNotEmpty) {
      // Tenter de charger les favoris
      final fetchedFavorites = await ApiService.getFavorites();
      
      setState(() {
        posts = allPosts;
        
        // Marquer les publications favorites
        for (var post in posts) {
          post.isFavorite = fetchedFavorites.any((favorite) => favorite.id == post.id);
        }
        
        favoritePosts = posts.where((post) => post.isFavorite).toList();
        isLoading = false;
        isOfflineMode = false;
      });
    } else {
      throw Exception("Pas de données disponibles");
    }
  } catch (e) {
    debugPrint('Erreur lors du chargement des données: $e');
    
    setState(() {
      // Utiliser seulement les posts statiques en cas d'erreur
      posts = staticPosts;
      favoritePosts = [];
      isLoading = false;
      isOfflineMode = true;
    });
    
    _showSnackBar(
      message: 'Mode hors ligne activé. Utilisation des données locales.',
      backgroundColor: Colors.orange,
      icon: Icons.cloud_off,
    );
  }
}

Future<void> _deletePost(Post post) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Supprimer la publication'),
      content: Text('Êtes-vous sûr de vouloir supprimer cette publication ? Cette action est irréversible.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Annuler', style: TextStyle(color: Colors.grey.shade700)),
        ),  // Cette parenthèse fermante manquait
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  if (shouldDelete == true) {
    try {
      // Pour les posts statiques, on ne peut pas vraiment les supprimer de l'API
      // donc on les supprime juste localement
      setState(() {
        posts.removeWhere((p) => p.id == post.id);
        favoritePosts.removeWhere((p) => p.id == post.id);
      });
      
      _showSnackBar(
        message: 'Publication supprimée',
        backgroundColor: Colors.green,
        icon: Icons.check,
      );
    } catch (e) {
      _showSnackBar(
        message: 'Erreur lors de la suppression',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }
}


  Future<void> _toggleFavorite(Post post) async {
    final previousState = post.isFavorite;
    
    setState(() {
      post.isFavorite = !post.isFavorite;
      _updateFavoritesList();
    });
    
    try {
      final result = await ApiService.toggleFavorite(post.id);
      
      // Si l'API renvoie un résultat différent, revenir en arrière
      if (result != post.isFavorite) {
        setState(() {
          post.isFavorite = result;
          _updateFavoritesList();
        });
      }
      
      // Afficher un message de confirmation
      _showSnackBar(
        message: post.isFavorite 
            ? 'Ajouté aux favoris' 
            : 'Retiré des favoris',
        backgroundColor: post.isFavorite 
            ? Colors.green 
            : Colors.grey.shade700,
        icon: post.isFavorite 
            ? Icons.favorite 
            : Icons.favorite_border,
      );
    } catch (e) {
      // En cas d'erreur, revenir à l'état précédent
      setState(() {
        post.isFavorite = previousState;
        _updateFavoritesList();
      });
      
      _showSnackBar(
        message: 'Erreur lors de la mise à jour des favoris',
        backgroundColor: Colors.red,
      );
    }
  }

  void _updateFavoritesList() {
    favoritePosts = posts.where((post) => post.isFavorite).toList();
  }

  void _showSnackBar({
    required String message,
    Color? backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              SizedBox(width: 8),
            ],
            Text(message),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  Future<void> _addComment(Post post) async {
    final TextEditingController commentController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.comment_outlined, color: Theme.of(context).primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Ajouter un commentaire',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'Votre commentaire...',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Annuler'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (commentController.text.isNotEmpty) {
                          Navigator.pop(context, commentController.text);
                        }
                      },
                      icon: Icon(Icons.send),
                      label: Text('Publier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((commentText) async {
      if (commentText != null && commentText.isNotEmpty) {
        _showSnackBar(
          message: 'Envoi du commentaire...',
          backgroundColor: Colors.grey.shade700,
          icon: Icons.sync,
          duration: Duration(seconds: 1),
        );
        
        try {
          // Envoyer le commentaire à l'API
          final comment = await ApiService.addComment(post.id, commentText);
          
          if (comment != null) {
            setState(() {
              post.commentsList.add(comment);
              post.comments++;
            });
            
            // Confirmation
            _showSnackBar(
              message: 'Commentaire ajouté',
              backgroundColor: Colors.green,
              icon: Icons.check_circle,
            );
          } else {
            throw Exception("Erreur lors de l'ajout du commentaire");
          }
        } catch (e) {
          // Gestion des erreurs
          _showSnackBar(
            message: 'Erreur: impossible d\'ajouter le commentaire',
            backgroundColor: Colors.red,
            icon: Icons.error,
          );
        }
      }
    });
  }

  Future<void> _createNewPost() async {
  if (_postController.text.isEmpty || selectedTag == null) {
    _showSnackBar(
      message: 'Veuillez remplir tous les champs',
      backgroundColor: Colors.red.shade400,
      icon: Icons.error,
    );
    return;
  }

  // Déterminer la couleur et le texte de l'avatar
  final String avatarText = 'KE'; // User
  final Color avatarColor = const Color.fromARGB(255, 56, 67, 224);

  // Création d'un post temporaire
  final tempPost = Post(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    avatarText: avatarText,
    avatarColor: avatarColor,
    title: 'Mon Post',
    content: _postController.text,
    time: 'À l\'instant',
    isVerified: false,
    tag: selectedTag!,
    likes: 0,
    comments: 0,
    shares: 0,
    commentsList: [],
  );

  // Ajouter localement le post pour une meilleure UX
  setState(() {
    posts.insert(0, tempPost);
    _postController.clear();
    selectedTag = null;
  });

  _showSnackBar(
    message: 'Publication en cours...',
    backgroundColor: Colors.grey.shade700,
    icon: Icons.sync,
  );

  try {
    // Envoyer le post au serveur
    final createdPost = await ApiService.createPost(tempPost);
    
    // Mettre à jour l'ID et autres propriétés potentiellement modifiées par le serveur
    setState(() {
      final index = posts.indexWhere((post) => post.id == tempPost.id);
      if (index != -1) {
        posts[index] = createdPost;
      }
    });
    
    _showSnackBar(
      message: 'Publication réussie!',
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  } catch (e) {
    _showSnackBar(
      message: 'Erreur lors de la publication. Réessayez plus tard.',
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
    
    // En cas d'erreur, on peut choisir de garder le post local ou de le supprimer
    // Ici on le garde pour ne pas perdre la saisie de l'utilisateur
  }
}
void _showPostDetails(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de drag
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Post
                  PostWidget(
                    post: post,
                    onFavoriteToggle: () {
                      _toggleFavorite(post);
                      setModalState(() {});
                    },
                    onLike: () async {
                      await ApiService.likePost(post.id);
                      setModalState(() {
                        post.likes++;
                      });
                    },
                    onShare: () async {
                      await ApiService.sharePost(post.id);
                      setModalState(() {
                        post.shares++;
                      });
                    },
                    onComment: () => _addComment(post).then((_) => setModalState(() {})),
                    showFullContent: true,
                  ),
                  Divider(height: 32),
                  // Titre des commentaires
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Commentaires (${post.comments})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Zone d'ajout de commentaire
                  GestureDetector(
                    onTap: () => _addComment(post).then((_) => setModalState(() {})),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color.fromARGB(255, 56, 67, 224),
                            child: Text(
                              'KE',
                              style: TextStyle(color: Colors.white),
                            ),
                            radius: 16,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Ajouter un commentaire...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Liste des commentaires
                  Expanded(
                    child: post.commentsList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Aucun commentaire pour le moment',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Soyez le premier à commenter',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: post.commentsList.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            return CommentWidget(
                              comment: post.commentsList[index],
                            );
                          },
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
Future<void> _refreshPosts() async {
  if (isRefreshing) return;
  
  setState(() {
    isRefreshing = true;
  });
  
  // Récupérer les posts statiques
  List<Post> staticPosts = ApiService._getDefaultPosts();
  List<String> staticPostIds = staticPosts.map((post) => post.id).toList();
  
  try {
    final refreshedPosts = await ApiService.getPosts();
    
    // Filtrer pour éviter les doublons avec les posts statiques
    List<Post> uniqueRefreshedPosts = refreshedPosts
        .where((post) => !staticPostIds.contains(post.id))
        .toList();
    
    // Combiner les posts statiques et les nouveaux posts
    List<Post> allPosts = [...staticPosts, ...uniqueRefreshedPosts];
    
    setState(() {
      // Conserver l'état des favoris
      for (var newPost in allPosts) {
        final existingPost = posts.firstWhere(
          (p) => p.id == newPost.id,
          orElse: () => newPost,
        );
        newPost.isFavorite = existingPost.isFavorite;
      }
      
      posts = allPosts;
      _updateFavoritesList();
      isRefreshing = false;
    });
    
    _showSnackBar(
      message: 'Contenu mis à jour',
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  } catch (e) {
    setState(() {
      isRefreshing = false;
    });
    
    _showSnackBar(
      message: 'Erreur lors de la mise à jour',
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }
}

void _openCreatePostSheet() {
  selectedTag = null;
  _postController.clear();
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec avatar et titre
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [const Color.fromARGB(255, 56, 67, 224), const Color.fromARGB(255, 56, 67, 224)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 56, 67, 224).withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Text(
                      'KE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Créer une publication',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.grey.shade700),
                    ),
                  ),
                ),
              ],
            ),
            
            Divider(height: 32, thickness: 0.5, color: Colors.grey.shade200),
            
            // Champ de texte pour la publication
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _postController,
                decoration: InputDecoration(
                  hintText: 'Partagez une information santé...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontSize: 16),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Type d'information
            Text(
              'Type d\'information:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.grey.shade800,
              ),
            ),
            
            SizedBox(height: 12),
            
            // Tags colorés
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildColoredTagChip('true', 'Vrai', Colors.green),
                _buildColoredTagChip('doubt', 'Douteux', Colors.amber),
                _buildColoredTagChip('false', 'Faux', Colors.red),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Bouton de publication en bleu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _createNewPost();
                },
                icon: Icon(Icons.send, color: Colors.white),
                label: Text(
                  'Publier',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade600, // Bouton bleu
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.blue.withOpacity(0.4), // Ombre bleue
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Méthode modifiée pour les tags avec fonds transparents colorés et icônes spécifiques
Widget _buildColoredTagChip(String tag, String label, Color color) {
  bool isSelected = selectedTag == tag;
  
  // Déterminer l'icône à afficher selon le type
  IconData tagIcon;
  if (tag == 'true') {
    tagIcon = Icons.check_circle_outline;
  } else if (tag == 'doubt') {
    tagIcon = Icons.help_outline;
  } else { // false
    tagIcon = Icons.cancel_outlined;
  }
  
  return InkWell(
    onTap: () {
      setState(() {
        selectedTag = isSelected ? null : tag;
      });
    },
    borderRadius: BorderRadius.circular(30),
    child: AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              tagIcon,
              size: 18,
              color: isSelected ? color : color.withOpacity(0.7),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildTagChip(String tag, String label, Color color) {
    final isSelected = selectedTag == tag;
    
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: color,
      backgroundColor: color.withOpacity(0.1),
      checkmarkColor: Colors.white,
      onSelected: (selected) {
        setState(() {
          selectedTag = selected ? tag : null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InfoSanté'),
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Logique de recherche à implémenter
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed: () {
              // Logique de notifications à implémenter
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Fil d\'actualité'),
            Tab(text: 'Favoris'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Fil d'actualité
                RefreshIndicator(
                  onRefresh: _refreshPosts,
                  child: posts.isEmpty
                      ? Center(
                          child: Text('Aucune publication disponible'),
                        )
                      : ListView.builder(
                          itemCount: posts.length,
                          padding: EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            return PostWidget(
                              post: posts[index],
                              onFavoriteToggle: () => _toggleFavorite(posts[index]),
                              onComment: () => _addComment(posts[index]),
                              onLike: () async {
                                await ApiService.likePost(posts[index].id);
                                setState(() {
                                  posts[index].likes++;
                                });
                              },
                              onShare: () async {
                                await ApiService.sharePost(posts[index].id);
                                setState(() {
                                  posts[index].shares++;
                                });
                              },
                                  onDelete: () => _deletePost(posts[index]), 
                              onTap: () => _showPostDetails(posts[index]),
                            );
                          },
                        ),
                ),
                // Favoris
                RefreshIndicator(
                  onRefresh: () async {
                    await ApiService.getFavorites().then((fetchedFavorites) {
                      setState(() {
                        favoritePosts = fetchedFavorites;
                      });
                    });
                  },
                  child: favoritePosts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucun favori pour le moment',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Marquez des publications comme favorites\npour les retrouver facilement',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: favoritePosts.length,
                          padding: EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            return PostWidget(
                              post: favoritePosts[index],
                              onFavoriteToggle: () => _toggleFavorite(favoritePosts[index]),
                              onComment: () => _addComment(favoritePosts[index]),
                              onLike: () async {
                                await ApiService.likePost(favoritePosts[index].id);
                                setState(() {
                                  favoritePosts[index].likes++;
                                });
                              },
                              onShare: () async {
                                await ApiService.sharePost(favoritePosts[index].id);
                                setState(() {
                                  favoritePosts[index].shares++;
                                });
                              },
                              onTap: () => _showPostDetails(favoritePosts[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePostSheet,
        child: Icon(Icons.add),
        tooltip: 'Créer une publication',
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    super.dispose();
  }
}

// Widget pour afficher une publication individuelle
class PostWidget extends StatelessWidget {
  final Post post;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onComment;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback? onTap;
  final bool showFullContent;
   final VoidCallback? onDelete;
  const PostWidget({
    Key? key,
    required this.post,
    required this.onFavoriteToggle,
    required this.onComment,
    required this.onLike,
    required this.onShare,
    this.onTap,
    this.onDelete, // Ajouter ce paramètre
    this.showFullContent = false,
  }) : super(key: key);

  @override
Widget build(BuildContext context) {
  // Définir les couleurs en fonction du tag
  Color tagColor;
  String tagText;
  IconData tagIcon;

  switch (post.tag) {
    case 'true':
      tagColor = Colors.green;
      tagText = 'Information vérifiée';
      tagIcon = Icons.check_circle;
      break;
    case 'doubt':
      tagColor = Colors.orange;
      tagText = 'Information à vérifier';
      tagIcon = Icons.help;
      break;
    case 'false':
      tagColor = Colors.red;
      tagText = 'Information incorrecte';
      tagIcon = Icons.cancel;
      break;
    default:
      tagColor = Colors.grey;
      tagText = 'Non évalué';
      tagIcon = Icons.info_outline;
  }

  return Card(
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du post
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: post.avatarColor,
                  child: Text(
                    post.avatarText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (post.isVerified) ...[
                            SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        post.time,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // AJOUTER LE BOUTON DE SUPPRESSION ICI
              if (onDelete != null)
  IconButton(
    icon: Icon(Icons.delete_outline, color: Colors.red),
    onPressed: onDelete,
    splashRadius: 20,
  ),
IconButton(
  icon: Icon(
    post.isFavorite ? Icons.favorite : Icons.favorite_border,
    color: post.isFavorite ? Colors.red : Colors.grey,
  ),
  onPressed: onFavoriteToggle,
  splashRadius: 20,
),
],
),
SizedBox(height: 12),
            // Contenu du post
            Text(
              post.content,
              style: TextStyle(fontSize: 15),
              maxLines: showFullContent ? null : 5,
              overflow: showFullContent ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            // Badge pour le type d'info
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tagColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tagIcon,
                    size: 16,
                    color: tagColor,
                  ),
                  SizedBox(width: 4),
                  Text(
                    tagText,
                    style: TextStyle(
                      color: tagColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Actions (like, comment, share)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.thumb_up_alt_outlined,
                  label: '${post.likes}',
                  onPressed: onLike,
                ),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.comments}',
                  onPressed: onComment,
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: '${post.shares}',
                  onPressed: onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}



  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        textStyle: TextStyle(fontSize: 13),
      ),
    );
  }
}