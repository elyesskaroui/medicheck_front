class Article {
  final String title;
  final String description;
  final String url;
  final String content;
  final String? author;
  final String? urlToImage;
  final DateTime publishedAt;
  bool isBookmarked;
  int likeCount;
  int dislikeCount;
  bool isLiked; // New property to track if user liked this article
  bool isDisliked; // New property to track if user disliked this article
  final String? _id;  // Make _id private

  // Constructor with _id field
  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.content,
    this.author,
    this.urlToImage,
    required this.publishedAt,
    this.isBookmarked = false,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.isLiked = false,
    this.isDisliked = false,
    String? id,  // Constructor should accept id as an optional field
  }) : _id = id;

  // Getter for the 'id' field to provide compatibility with the frontend code
  String get id => _id ?? title; // Fallback to title if _id is not available

  // Factory method to create an Article from JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      url: json['url'] ?? '',
      content: json['content'] ?? 'No Content Available',
      author: json['author'] ?? 'Unknown Author',
      urlToImage: json['urlToImage'] ?? 'https://via.placeholder.com/150',
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt']) 
          : DateTime.now(),
      isBookmarked: false,
      likeCount: json['likeCount'] ?? 0,
      dislikeCount: json['dislikeCount'] ?? 0,
      isLiked: false,
      isDisliked: false,
      id: json['_id'],
    );
  }
}