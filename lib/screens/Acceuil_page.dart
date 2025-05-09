import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/AnalysisScreen.dart';
import 'package:flutter_application_1/screens/medication_analysis_screen.dart';
import 'package:flutter_application_1/screens/news_screen.dart';
import 'package:flutter_application_1/screens/health_assistant_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/viewmodels/news_viewmodel.dart';
import 'package:flutter_application_1/models/article.dart';

class AcceuilPage extends StatefulWidget {
  const AcceuilPage({super.key});

  @override
  State<AcceuilPage> createState() => _AcceuilPageState();
}

class _AcceuilPageState extends State<AcceuilPage> {
  List<Article> recentArticles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentArticles();
  }

  Future<void> _loadRecentArticles() async {
    final viewModel = NewsViewModel();
    try {
      await viewModel.loadArticles();
      setState(() {
        // Get the 2 most recent articles
        recentArticles = viewModel.articles.take(2).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading articles: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher des articles ...',
                          fillColor: Colors.grey[200],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Utilisation de MaterialPageRoute au lieu de la navigation nommée
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HealthAssistantScreen(),
                          ),
                        );
                      } catch (e) {
                        print('Erreur de navigation: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.health_and_safety, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Assistant Santé',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AnalysisScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: const Text('Analyse fausses informations',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MedicationAnalysisScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medication, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Analyse de Médicament',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Wrap NewsScreen with ChangeNotifierProvider to fix the provider issue
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => NewsViewModel(),
                            child: NewsScreen(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.article, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'File d\'actualité médicale',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Les fausses informations peuvent être mortelles. Ne partagez pas avant de vérifier.',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                const Text('Historique',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // Show loading indicator while fetching articles
                isLoading
                ? Center(child: CircularProgressIndicator())
                : recentArticles.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun rapport médical récent',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Row(
                      children: [
                        // First article
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (recentArticles.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangeNotifierProvider(
                                      create: (_) => NewsViewModel(),
                                      child: NewsScreen(),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              children: [
                                // Article image
                                recentArticles.isNotEmpty && recentArticles[0].urlToImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        recentArticles[0].urlToImage!,
                                        width: MediaQuery.of(context).size.width * 0.4,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: MediaQuery.of(context).size.width * 0.4,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                    ),
                                const SizedBox(height: 5),
                                // Article title
                                Text(
                                  recentArticles.isNotEmpty 
                                    ? recentArticles[0].title 
                                    : 'Rapport médical',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                // Publication date
                                Text(
                                  'Il y a 2 jours',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Second article
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (recentArticles.length > 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangeNotifierProvider(
                                      create: (_) => NewsViewModel(),
                                      child: NewsScreen(),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              children: [
                                // Article image
                                recentArticles.length > 1 && recentArticles[1].urlToImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        recentArticles[1].urlToImage!,
                                        width: MediaQuery.of(context).size.width * 0.4,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: MediaQuery.of(context).size.width * 0.4,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                    ),
                                const SizedBox(height: 5),
                                // Article title
                                Text(
                                  recentArticles.length > 1 
                                    ? recentArticles[1].title 
                                    : 'Rapport médical',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                // Publication date
                                Text(
                                  'Il y a 4 jours',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Utilisation de MaterialPageRoute au lieu de la navigation nommée
          try {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HealthAssistantScreen(),
              ),
            );
          } catch (e) {
            print('Erreur de navigation FAB: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur FAB: $e')),
            );
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.medical_services, color: Colors.white),
        tooltip: 'Assistant Santé',
      ),
    );
  }
}