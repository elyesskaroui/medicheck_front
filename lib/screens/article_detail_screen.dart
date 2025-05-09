import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchAuthorWikipedia(String authorName) async {
    final searchQuery = Uri.encodeComponent(authorName);
    final wikiUrl = 'https://en.wikipedia.org/wiki/$searchQuery';

    try {
      final response = await http.get(Uri.parse(wikiUrl));
      if (response.statusCode == 200 &&
          !response.body.contains('may refer to') &&
          !response.body.contains('search')) {
        await _launchURL(wikiUrl);
      } else {
        await _launchURL('https://www.google.com/search?q=$searchQuery');
      }
    } catch (_) {
      await _launchURL('https://www.google.com/search?q=$searchQuery');
    }
  }

  void _showShareOptions(BuildContext context, String url) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _shareIcon(context, FontAwesomeIcons.whatsapp, "WhatsApp", () => Share.share(url)),
                  _shareIcon(context, FontAwesomeIcons.facebook, "Facebook", () => Share.share(url)),
                  _shareIcon(context, Icons.email, "Email", () => Share.share(url)),
                  _shareIcon(context, Icons.link, "Copy", () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied!')),
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shareIcon(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0077B6), // Healthcare blue
        title: Text(
          article.title,
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              Hero(
                tag: article.urlToImage!,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: article.urlToImage!,
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                    imageErrorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: Icon(Icons.broken_image, size: 60, color: Colors.grey[600]),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.image_not_supported, size: 60),
              ),
            const SizedBox(height: 20),

            // Title and Description
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                article.title,
                key: ValueKey(article.title),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 600),
              child: Text(
                article.description,
                style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 20),

            // Author Card
            if (article.author != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(article.author!),
                  subtitle: const Text('Tap to view more'),
                  onTap: () => _launchAuthorWikipedia(article.author!),
                ),
              ),

            // Source Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.link),
                title: Text('Source'),
                subtitle: Text(article.url),
                onTap: () => _launchURL(article.url),
              ),
            ),

            const SizedBox(height: 20),

            // Article Content
            Text(
              article.content,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            ),

            const SizedBox(height: 30),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _launchURL(article.url),
                  icon: const Icon(Icons.read_more, color: Colors.white),
                  label: const Text('Read More', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showShareOptions(context, article.url),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text('Share', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0096C7),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}