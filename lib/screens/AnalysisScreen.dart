import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/screens/text_input_field.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;
  String _analysisResult = '';
  final ApiService _apiService = ApiService();
  int _currentIndex = 1; // Définit l'index actuel de la navbar

  @override
  void initState() {
    super.initState();
    // Check connectivity when screen initializes
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    try {
      final testPrompt = "test connection";
      await _apiService.analyzeText(testPrompt);
      print("API connection successful");
    } catch (e) {
      print("API connection check failed: $e");
      // Only show the error message if the widget is still mounted
      if (mounted) {
        _showSnackBar('Cannot connect to analysis server. Please check your connection.', Colors.orange);
      }
    }
  }

  void _analyzeText() async {
    if (_promptController.text.isEmpty) {
      _showSnackBar('Please enter a prompt.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = '';
    });

    try {
      final result = await _apiService.analyzeText(_promptController.text);

      setState(() {
        if (result != null) {
          _analysisResult = result;
        } else {
          _analysisResult = 'Failed to analyze text. Please try again.';
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Analysis error: $e');
      setState(() {
        _analysisResult = 'Analysis failed: ${e.toString()}';
        _isLoading = false;
      });
      _showSnackBar('Analysis failed. Please check your connection.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Navigation vers les autres écrans
    switch (index) {
      case 0: // Accueil
        Navigator.of(context).pushReplacementNamed('/main');
        break;
      case 1: // Analyse (page actuelle)
        // Déjà sur cette page
        break;
      case 2: // Chat
        Navigator.of(context).pushReplacementNamed('/chat');
        break;
      case 3: // Profil
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse de Texte Médical'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header text
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vérification Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Entrez un texte médical pour analyser sa fiabilité',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Stylish input card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextInputField(
                      controller: _promptController,
                      icon: Icons.text_fields,
                      hint: 'Entrez votre texte ou question médicale',
                      inputType: TextInputType.text,
                      inputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _analyzeText,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : const Text(
                                'Analyser',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Result section
              if (_analysisResult.isNotEmpty)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics, color: primaryColor),
                            const SizedBox(width: 10),
                            Text(
                              'Résultats de l\'analyse',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                _analysisResult,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              // Empty state
              if (_analysisResult.isEmpty && !_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Entrez du texte et cliquez sur Analyser',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToPage,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analyse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}