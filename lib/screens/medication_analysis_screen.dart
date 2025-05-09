import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app-config.dart';
import 'package:flutter_application_1/services/api_service.dart';

class MedicationAnalysisScreen extends StatefulWidget {
  const MedicationAnalysisScreen({Key? key}) : super(key: key);

  @override
  _MedicationAnalysisScreenState createState() => _MedicationAnalysisScreenState();
}

class _MedicationAnalysisScreenState extends State<MedicationAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _imageUrlController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  String? _analysisResult;
  bool _isLoading = false;
  bool _imageLoadError = false;

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = null;
      _imageLoadError = false;
    });

    try {
      // Make sure URL is properly formatted
      String imageUrl = _imageUrlController.text.trim();
      if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
        imageUrl = 'https://$imageUrl';
        _imageUrlController.text = imageUrl;
      }
      
      final result = await _apiService.analyzeMedicationImage(imageUrl);
      
      setState(() {
        _analysisResult = result;
        _isLoading = false;
      });
    } catch (e) {
      print('Error analyzing image: $e');
      setState(() {
        _analysisResult = "Error: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse de Médicament'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analyse de Médicament',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Entrez l\'URL d\'une image de médicament pour obtenir des informations sur son nom et son utilisation.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL de l\'image',
                    hintText: 'www.exemple.com/image.jpg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.link),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une URL d\'image';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _analyzeImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Analyser',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_analysisResult != null) ...[
                  const Text(
                    'Résultat de l\'analyse:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Text(
                      _analysisResult!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (_imageUrlController.text.isNotEmpty) ...[
                  const Text(
                    'Image analysée:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.error, color: Colors.red, size: 40),
                                SizedBox(height: 8),
                                Text(
                                  'Impossible de charger l\'image',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}