import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/who_service.dart';

class HealthAssistantScreen extends StatefulWidget {
  const HealthAssistantScreen({super.key});

  @override
  State<HealthAssistantScreen> createState() => _HealthAssistantScreenState();
}

class _HealthAssistantScreenState extends State<HealthAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final WHOService _whoService = WHOService();
  
  @override
  void initState() {
    super.initState();
    
    // Add welcome message immediately
    _messages.add({
      'isUser': false,
      'text': "Bonjour, je suis votre assistant médical. Comment puis-je vous aider aujourd'hui?"
    });
  }

  void _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      // Add user message
      _messages.add({
        'isUser': true,
        'text': text
      });
      
      // Clear text field
      _textController.clear();
      
      // Show loading indicator
      _isLoading = true;
    });
    
    try {
      // Get response from WHO service
      final response = await _whoService.getResponse(text);
      
      if (mounted) {
        setState(() {
          // Add response from service
          _messages.add({
            'isUser': false,
            'text': response
          });
          
          // Hide loading indicator
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error getting response: $e');
      if (mounted) {
        setState(() {
          // Add fallback response in case of error
          _messages.add({
            'isUser': false,
            'text': "Je suis désolé, je n'ai pas pu traiter votre demande. Pouvez-vous reformuler votre question?"
          });
          
          // Hide loading indicator
          _isLoading = false;
        });
      }
    }
  }
  
  void _showVoicePermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fonctionnalité vocale temporairement désactivée'),
        content: const Text(
          'La fonctionnalité de reconnaissance vocale est temporairement désactivée '
          'pour résoudre un problème technique. Veuillez utiliser le clavier pour saisir vos questions.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant Santé'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Simply pop back to previous screen
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Message area
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'] as bool;
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Text(
                      message['text'] as String,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'En train d\'écrire...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          
          // Text input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Disabled Microphone button with info tooltip
                IconButton(
                  icon: const Icon(
                    Icons.mic_off,
                    color: Colors.grey,
                  ),
                  onPressed: _showVoicePermissionDialog,
                  tooltip: 'Fonctionnalité vocale temporairement désactivée',
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}