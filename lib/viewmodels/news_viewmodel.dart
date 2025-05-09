import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import '../models/article.dart';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Article> _articles = [];
  List<Article> _bookmarkedArticles = [];
  bool _isLoading = false;
  bool _isBookmarksLoading = false;
  bool _isUserLoggedIn = false;

  final Box _readArticlesBox = Hive.box('readArticlesBox');
  final Box _reactionsBox = Hive.box('userReactionsBox');

  NewsViewModel() {
    // Check if user is logged in
    _checkUserLoginStatus();
  }

  List<Article> get articles => _articles;
  List<Article> get bookmarkedArticles => _bookmarkedArticles;
  bool get isLoading => _isLoading;
  bool get isBookmarksLoading => _isBookmarksLoading;
  bool get isUserLoggedIn => _isUserLoggedIn;

  // Check user login status
  Future<void> _checkUserLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    _isUserLoggedIn = token != null && token.isNotEmpty;
    
    if (_isUserLoggedIn) {
      // Load bookmarks if user is logged in
      loadUserBookmarks();
    }
  }

  // Load articles from API
  Future<void> loadArticles() async {
    _isLoading = true;
    notifyListeners();

    try {
      _articles = await _apiService.fetchArticles();
      
      // If logged in, update bookmark status for each article
      if (_isUserLoggedIn) {
        await _updateArticleBookmarkStatus();
      }
      
      // Load reaction status for each article
      _loadArticleReactions();
    } catch (e) {
      print("Error fetching articles: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load user bookmarks
  Future<void> loadUserBookmarks() async {
    if (!_isUserLoggedIn) return;
    
    _isBookmarksLoading = true;
    notifyListeners();

    try {
      _bookmarkedArticles = await _apiService.getBookmarkedArticles();
      
      // Update bookmark status for all loaded articles
      if (_articles.isNotEmpty) {
        await _updateArticleBookmarkStatus();
      }
    } catch (e) {
      print("Error loading bookmarks: $e");
    }

    _isBookmarksLoading = false;
    notifyListeners();
  }

  // Update bookmark status for all articles
  Future<void> _updateArticleBookmarkStatus() async {
    if (!_isUserLoggedIn) return;
    
    // Get set of bookmarked article IDs for faster lookup
    final bookmarkedIds = _bookmarkedArticles.map((a) => a.id).toSet();
    
    // Update isBookmarked flag for all articles
    for (int i = 0; i < _articles.length; i++) {
      _articles[i].isBookmarked = bookmarkedIds.contains(_articles[i].id);
    }
  }

  // Load reaction status for articles
  void _loadArticleReactions() {
    for (int i = 0; i < _articles.length; i++) {
      String key = 'reaction_${_articles[i].id}';
      String? reaction = _reactionsBox.get(key);
      
      // Reset reaction state
      _articles[i].isLiked = false;
      _articles[i].isDisliked = false;
      
      // Apply saved reaction
      if (reaction == 'like') {
        _articles[i].isLiked = true;
      } else if (reaction == 'dislike') {
        _articles[i].isDisliked = true;
      }
    }
  }

  // Toggle bookmark status for an article
  Future<void> toggleBookmark(Article article) async {
    // If not logged in, show a message
    if (!_isUserLoggedIn) {
      print("User needs to login to bookmark articles");
      // You can show a dialog here to prompt login
      return;
    }
    
    final index = _articles.indexOf(article);
    if (index == -1) return;
    
    try {
      bool success;
      
      if (_articles[index].isBookmarked) {
        // Remove bookmark
        success = await _apiService.removeBookmark(_articles[index].id);
        if (success) {
          _articles[index].isBookmarked = false;
          _bookmarkedArticles.removeWhere((a) => a.id == _articles[index].id);
        }
      } else {
        // Add bookmark
        success = await _apiService.addBookmark(_articles[index].id);
        if (success) {
          _articles[index].isBookmarked = true;
          
          // Add to bookmarked list if not already there
          if (!_bookmarkedArticles.any((a) => a.id == _articles[index].id)) {
            _bookmarkedArticles.add(_articles[index]);
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      print("Error toggling bookmark: $e");
    }
  }

  // Like/dislike with proper count handling
  Future<void> likeArticle(String articleId) async {
    try {
      final index = _articles.indexWhere((a) => a.id == articleId);
      if (index == -1) return;
      
      // Get the article
      final article = _articles[index];
      String key = 'reaction_$articleId';
      String? currentReaction = _reactionsBox.get(key);
      
      // Handle reaction state:
      if (currentReaction == 'like') {
        // Already liked - do nothing
        return;
      } else if (currentReaction == 'dislike') {
        // Previously disliked - remove dislike and add like
        article.isDisliked = false;
        
        // Update UI immediately for responsiveness
        article.likeCount = 1; // Set like to 1
        article.dislikeCount = 0; // Reset dislike to 0
        article.isLiked = true;
        
        // Store the new reaction
        await _reactionsBox.put(key, 'like');
        
        // Update the server (you may need to adjust this based on your API)
        await _apiService.dislikeArticle(articleId); // Cancel dislike
        await _apiService.likeArticle(articleId); // Add like
      } else {
        // No previous reaction - add like
        article.isLiked = true;
        article.likeCount = 1;
        
        // Store the reaction
        await _reactionsBox.put(key, 'like');
        
        // Update the server
        await _apiService.likeArticle(articleId);
      }
      
      notifyListeners();
    } catch (e) {
      print("❌ Error handling like: $e");
    }
  }

  Future<void> dislikeArticle(String articleId) async {
    try {
      final index = _articles.indexWhere((a) => a.id == articleId);
      if (index == -1) return;
      
      // Get the article
      final article = _articles[index];
      String key = 'reaction_$articleId';
      String? currentReaction = _reactionsBox.get(key);
      
      // Handle reaction state:
      if (currentReaction == 'dislike') {
        // Already disliked - do nothing
        return;
      } else if (currentReaction == 'like') {
        // Previously liked - remove like and add dislike
        article.isLiked = false;
        
        // Update UI immediately for responsiveness
        article.dislikeCount = 1; // Set dislike to 1
        article.likeCount = 0; // Reset like to 0
        article.isDisliked = true;
        
        // Store the new reaction
        await _reactionsBox.put(key, 'dislike');
        
        // Update the server (you may need to adjust this based on your API)
        await _apiService.likeArticle(articleId); // Cancel like
        await _apiService.dislikeArticle(articleId); // Add dislike
      } else {
        // No previous reaction - add dislike
        article.isDisliked = true;
        article.dislikeCount = 1;
        
        // Store the reaction
        await _reactionsBox.put(key, 'dislike');
        
        // Update the server
        await _apiService.dislikeArticle(articleId);
      }
      
      notifyListeners();
    } catch (e) {
      print("❌ Error handling dislike: $e");
    }
  }

  // Mark as Read Feature
  Future<void> markArticleAsRead(String articleId) async {
    await _readArticlesBox.put(articleId, true);
    notifyListeners();
  }

  bool isArticleRead(String articleId) {
    return _readArticlesBox.get(articleId, defaultValue: false);
  }

  void removeArticle(Article article) {
    _articles.removeWhere((a) => a.id == article.id);
    notifyListeners();
  }
}