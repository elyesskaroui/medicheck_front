import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  Function(String)? onError;
  Function(String)? _onResult;
  String _currentText = '';

  Future<bool> initialize({Function(String)? onErrorCallback}) async {
    onError = onErrorCallback;
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) {
          String message = 'Erreur de reconnaissance vocale';
          
          switch (error.errorMsg) {
            case 'no-speech':
              message = 'Aucune parole détectée. Veuillez parler plus fort ou vérifier votre microphone.';
              break;
            case 'network':
              message = 'Erreur de connexion réseau. Vérifiez votre connexion internet.';
              break;
            case 'not-allowed':
              message = 'L\'accès au microphone n\'est pas autorisé. Veuillez vérifier les permissions.';
              break;
            case 'speech-timeout':
              message = 'Temps d\'attente dépassé. Veuillez réessayer.';
              break;
            default:
              message = 'Erreur: ${error.errorMsg}';
          }
          
          onError?.call(message);
          print('Erreur de reconnaissance vocale: ${error.errorMsg}');
        },
        debugLogging: true,
      );
    }
    return _isInitialized;
  }

  bool get isListening => _speech.isListening;

  Future<bool> startListening({
    required Function(String text) onResult,
    String languageCode = 'fr_FR',
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call('Impossible d\'initialiser la reconnaissance vocale. Veuillez vérifier les permissions du microphone.');
        return false;
      }
    }

    _currentText = '';
    _onResult = onResult;

    return await _speech.listen(
      onResult: (result) {
        // Mettre à jour le texte actuel
        _currentText = result.recognizedWords;
        
        // Si c'est un résultat final ou si on a une phrase complète
        if (result.finalResult || _currentText.contains('.') || _currentText.contains('?')) {
          _onResult?.call(_currentText);
          _currentText = '';
        }
      },
      localeId: languageCode,
      listenMode: stt.ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onSoundLevelChange: (level) {
        // Vous pouvez utiliser le niveau sonore pour donner un retour visuel
        print('Niveau sonore: $level');
      },
    );
  }

  Future<void> stopListening() async {
    // Si on a du texte non envoyé, l'envoyer avant d'arrêter
    if (_currentText.isNotEmpty) {
      _onResult?.call(_currentText);
    }
    await _speech.stop();
    _onResult = null;
  }

  void cancel() {
    _currentText = '';
    _speech.cancel();
    _onResult = null;
  }

  Future<List<String>> getLocales() async {
    final locales = await _speech.locales();
    return locales.map((locale) => locale.localeId).toList();
  }
}
