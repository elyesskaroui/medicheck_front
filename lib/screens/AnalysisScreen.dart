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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Text Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextInputField(
              controller: _promptController,
              icon: Icons.text_fields,
              hint: 'Enter your medical text or question',
              inputType: TextInputType.text,
              inputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: _isLoading ? 70 : 150,
                height: 50,
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey : Colors.blue,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : TextButton(
                        onPressed: _analyzeText,
                        child: const Text(
                          'Analyze',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            if (_analysisResult.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _analysisResult,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}