import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/article_detail_screen.dart';
import '../models/article.dart';

class NewsCard extends StatelessWidget {
  final Article article;

  NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: article.urlToImage != null
            ? Image.network(article.urlToImage!, width: 80, fit: BoxFit.cover)
            : null,
        title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(article.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
          );
        },
      ),
    );
  }
}
