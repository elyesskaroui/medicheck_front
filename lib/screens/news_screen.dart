import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/news_viewmodel.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';
import 'bookmarked_articles_screen.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _searchQuery = '';
  String _sortOption = 'Newest';
  
  @override
  void initState() {
    super.initState();
    // Load articles when the screen is first initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsViewModel>(context, listen: false).loadArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsViewModel = Provider.of<NewsViewModel>(context);

    List<Article> filteredArticles = newsViewModel.articles
        .where((article) =>
            article.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    sortArticles(filteredArticles, _sortOption);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medical News',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmarks, color: Colors.white),
            onPressed: () {
              // Use ChangeNotifierProvider.value to share the same NewsViewModel instance
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: newsViewModel,
                    child: BookmarkedArticlesScreen(),
                  ),
                ),
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: newsViewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredArticles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No articles found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => newsViewModel.loadArticles(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2196F3),
                        ),
                        child: Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search articles...',
                                prefixIcon: Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: PopupMenuButton<String>(
                              icon: Icon(Icons.sort),
                              tooltip: 'Sort articles',
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              onSelected: (value) {
                                setState(() {
                                  _sortOption = value;
                                });
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'Newest',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        color: _sortOption == 'Newest'
                                            ? Colors.blue
                                            : Colors.grey,
                                        size: 18,
                                      ),
                                      SizedBox(width: 10),
                                      Text('Newest First'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'Oldest',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        color: _sortOption == 'Oldest'
                                            ? Colors.blue
                                            : Colors.grey,
                                        size: 18,
                                      ),
                                      SizedBox(width: 10),
                                      Text('Oldest First'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'Alphabetical',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.sort_by_alpha,
                                        color: _sortOption == 'Alphabetical'
                                            ? Colors.blue
                                            : Colors.grey,
                                        size: 18,
                                      ),
                                      SizedBox(width: 10),
                                      Text('A-Z'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sorted by: $_sortOption',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredArticles.length,
                          itemBuilder: (context, index) {
                            Article article = filteredArticles[index];
                            bool isRead = newsViewModel.isArticleRead(article.id);

                            return Opacity(
                              opacity: isRead ? 0.5 : 1.0, // Lower opacity if read
                              child: Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      offset: Offset(0, 5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.black.withOpacity(0.1),
                                  child: Column(
                                    children: [
                                      article.urlToImage != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                              child: Image.network(
                                                article.urlToImage!,
                                                width: double.infinity,
                                                height: 200,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Container(
                                                    height: 200,
                                                    child: Center(
                                                      child: CircularProgressIndicator(),
                                                    ),
                                                  );
                                                },
                                                errorBuilder:
                                                    (context, error, stackTrace) {
                                                  return Container(
                                                    height: 200,
                                                    child: Center(
                                                      child: Icon(Icons.broken_image, size: 50),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Container(
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(Icons.image_not_supported, size: 50),
                                              ),
                                            ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    article.title,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    // Bookmark button
                                                    IconButton(
                                                      icon: Icon(
                                                        article.isBookmarked
                                                            ? Icons.bookmark
                                                            : Icons.bookmark_border,
                                                        color: article.isBookmarked
                                                            ? Colors.blue
                                                            : Colors.grey,
                                                      ),
                                                      onPressed: () {
                                                        newsViewModel.toggleBookmark(article);
                                                      },
                                                    ),
                                                    // Like button with visual feedback
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.thumb_up,
                                                        color: article.isLiked
                                                            ? Colors.green
                                                            : Colors.grey,
                                                      ),
                                                      onPressed: () {
                                                        newsViewModel.likeArticle(article.id);
                                                      },
                                                    ),
                                                    Text('${article.likeCount}'),
                                                    SizedBox(width: 8),
                                                    // Dislike button with visual feedback
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.thumb_down,
                                                        color: article.isDisliked
                                                            ? Colors.red
                                                            : Colors.grey,
                                                      ),
                                                      onPressed: () {
                                                        newsViewModel.dislikeArticle(article.id);
                                                      },
                                                    ),
                                                    Text('${article.dislikeCount}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              article.description,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 12),
                                            Divider(),
                                            SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      article.author ??
                                                          "Unknown Author",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontStyle: FontStyle.italic,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Published on: ${formatDate(article.publishedAt)}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await newsViewModel
                                                        .markArticleAsRead(
                                                            article.id);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ArticleDetailScreen(
                                                          article: article,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    "Read More",
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight: FontWeight.bold,
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
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void sortArticles(List<Article> articles, String sortOption) {
    switch (sortOption) {
      case 'Newest':
        articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        break;
      case 'Oldest':
        articles.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
        break;
      case 'Alphabetical':
        articles.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}