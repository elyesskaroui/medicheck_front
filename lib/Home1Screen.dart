import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Services/config.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:percent_indicator/linear_percent_indicator.dart';

void main() {
  runApp(const MedInfoVerifierApp());
}

class MedInfoVerifierApp extends StatelessWidget {
  const MedInfoVerifierApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vérificateur d\'Informations Médicales',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A6EB4),
          brightness: Brightness.light,
        ),
        fontFamily: 'Montserrat',
      ),
      home: const MedInfoVerifierHome(),
    );
  }
}

class MedInfoVerifierHome extends StatefulWidget {
  const MedInfoVerifierHome({Key? key}) : super(key: key);

  @override
  State<MedInfoVerifierHome> createState() => _MedInfoVerifierHomeState();
}

class _MedInfoVerifierHomeState extends State<MedInfoVerifierHome>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool _isVerifying = false;
  bool? _isVerified;
  String _verificationMessage = '';
  String accuracy = '0%';

  // Animation controllers
  late List<AnimationController> _floatingIconControllers;
  late AnimationController _popupAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();

    // Contrôleurs pour les icônes flottantes (réduits à 5 pour éviter les problèmes de performance)
    _floatingIconControllers = List.generate(5, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 3 + index),
      )..repeat(reverse: true);
    });

    // Contrôleur pour l'animation du popup
    _popupAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Animation pour le bouton
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Contrôleur pour l'animation d'arrière-plan
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();

    // Disposer tous les contrôleurs d'animation
    for (var controller in _floatingIconControllers) {
      controller.dispose();
    }
    _popupAnimationController.dispose();
    _buttonAnimationController.dispose();
    _backgroundController.dispose();

    super.dispose();
  }

  /***************************** */
  Future<Map<String, dynamic>?> startImageVerification() async {
    final imageUrl = _urlController.text;
    final url = Uri.parse(
        '${Config.baseUrl}/scraper/analyzeimage?imageUrl=$imageUrl');

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print(
            "Failed to analyze image: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error during image analysis: $e");
      return null;
    }
  }

/*-------------------------------*/
  Future<void> _verifyImage() async {
    setState(() {
      _isVerifying = true;
      _verificationMessage = "Analyse de l'image en cours...";
    });

    try {
      final imageUrl = _urlController.text.trim();

      // Validation de l'URL
      if (!Uri.parse(imageUrl).isAbsolute || !imageUrl.startsWith('http')) {
        setState(() {
          _isVerifying = false;
          _isVerified = false;
          _verificationMessage =
              'Veuillez entrer une URL d\'image valide commençant par http:// ou https://';
          accuracy = "0%";
        });
        _showVerificationResult(false);
        return;
      }

      final response = await startImageVerification();

      if (response == null) {
        setState(() {
          _isVerifying = false;
          _isVerified = false;
          _verificationMessage =
              "Échec de la communication avec le serveur. Veuillez réessayer.";
          accuracy = "0%";
        });
        _showVerificationResult(false);
        return;
      }

      // Extraire les informations de la réponse
      final success = response['success'] ?? false;
      final analysis = response['analysis'] as Map<String, dynamic>?;

      if (analysis == null) {
        setState(() {
          _isVerifying = false;
          _isVerified = false;
          _verificationMessage =
              "Données d'analyse manquantes dans la réponse.";
          accuracy = "0%";
        });
        _showVerificationResult(false);
        return;
      }

      final isRelated = analysis['related'] ?? false;
      final isFound = analysis['found'] ?? false;
      final details = analysis['details'] ?? 'Aucun détail fourni';

      // SOLUTION IMPORTANTE: Définir accuracy à 100% quand l'information est vérifiée
      bool isVerified = success && (isFound || isRelated);

      // Quand image est vérifiée, définir toujours l'accuracy à 100%
      String accuracyValue = isVerified ? "100" : "0";
      accuracy = "$accuracyValue%";

      // Formatage du message avec une description claire
      String displayMessage;
      if (isVerified) {
        // Inclure la description détaillée de l'image
        String imageDescription = "";

        // Essayer d'extraire une description d'image du texte de détails
        if (details.contains("Cette image montre") ||
            details.contains("L'image montre") ||
            details.contains("L'image représente") ||
            details.contains("On peut voir")) {
          imageDescription = details;
        } else {
          // Si pas de description explicite, utiliser tout le texte des détails
          imageDescription = "Description de l'image: $details";
        }

        displayMessage =
            'Information verified and found reliable. This information is confirmed by trusted medical sources.\n\n$imageDescription';
      } else {
        displayMessage =
            'Information could not be verified in trusted medical sources. We recommend consulting official health organizations for reliable information.';
      }

      setState(() {
        _isVerifying = false;
        _isVerified = isVerified;
        _verificationMessage = displayMessage;
      });

      _showVerificationResult(isVerified);
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _isVerified = false;
        _verificationMessage =
            'Erreur lors de l\'analyse de l\'image: ${e.toString()}';
        accuracy = "0%";
      });
      _showVerificationResult(false);
    }
  }

  /****************************** */
  double accuracyValue =
      0.0; // Valeur numérique pour le percent indicator (0.0-1.0)
  Future<void> _verifyInformation() async {
    print("clickedddd");
    setState(() {
      _isVerifying = true;
    });

    try {
      final info = _textController.text;
      final response = await startScraping();

      bool isTrusted = false;
      String message = 'Information could not be verified.';
      String accuracy = '0%'; // Réinitialisation avec valeur par défaut

      if (response != null) {
        final validResults = (response['results'] as List?)
                ?.where((r) => r['data'] != null)
                .toList() ??
            [];
        isTrusted = response['foundResults'] ?? false;

        if (isTrusted && validResults.isNotEmpty) {
          final firstResult =
              validResults.first['data'] as Map<String, dynamic>?;
          // Convertir en chaîne avec % si ce n'est pas déjà une chaîne
          var rawAccuracy = firstResult?['accuracy'];
          accuracy = rawAccuracy is String
              ? rawAccuracy
              : '${rawAccuracy ?? 0}%'; // Convertir int en String avec %
          message =
              'Information verified and found reliable. This information is confirmed by trusted medical sources.';
          final sources = validResults
              .map((r) => r['data']['source'] ?? 'Unknown source')
              .toList();
          if (sources.isNotEmpty) {
            message += '\n\nSources: ${sources.join(", ")}';
          }
        } else {
          message =
              'Information could not be verified in trusted medical sources. We recommend consulting official health organizations for reliable information.';
        }
      }

      setState(() {
        _isVerifying = false;
        _isVerified = isTrusted;
        _verificationMessage = message;
        this.accuracy = accuracy; // Mettre à jour la variable d'état
      });

      _showVerificationResult(isTrusted);
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _isVerified = false;
        _verificationMessage = 'Error during verification: ${e.toString()}';
        accuracy = '0%'; // Réinitialiser en cas d'erreur
      });
      _showVerificationResult(false);
    }
  }

  void _showVerificationResult(bool isRelated) {
    _popupAnimationController.reset();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: 340,
              constraints: const BoxConstraints(maxHeight: 500),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: isRelated
                        ? Colors.green.withOpacity(0.4)
                        : Colors.red.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 10),
                  )
                ],
                border: Border.all(
                  color: isRelated
                      ? Colors.green.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRelated) ...[
                      ResultIconWidget(
                        isVerified: isRelated,
                        controller: _popupAnimationController,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Checking everything health related',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Display the description with an improved design
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.shade300,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.1),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  color: Colors.green.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Description",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              // Use the actual verification message here
                              _verificationMessage.contains('Sources:')
                                  ? _verificationMessage
                                      .split('Sources:')
                                      .first
                                      .trim()
                                  : _verificationMessage.trim(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: Colors.grey.shade800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Improved circular percentage indicator with loading animation
                      Container(
                        width: 150,
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background circle with gradient for more depth
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.grey.shade200,
                                    Colors.grey.shade300,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                            ),
                            // Background progress circle
                            CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey.shade300.withOpacity(0.6),
                              ),
                            ),
                            // Loading animation when the value changes
                            TweenAnimationBuilder(
                              tween: Tween<double>(
                                begin: 0.0,
                                end: double.tryParse(
                                            accuracy.replaceAll('%', '')) !=
                                        null
                                    ? double.parse(
                                            accuracy.replaceAll('%', '')) /
                                        100
                                    : 0.0,
                              ),
                              duration: const Duration(milliseconds: 1500),
                              builder: (context, double value, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Main progress indicator
                                    CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 12,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          value > 0.7
                                              ? Colors.green.shade500
                                              : value > 0.4
                                                  ? Colors.orange
                                                  : Colors.red.shade500),
                                      strokeCap: StrokeCap.round,
                                    ),
                                    // Additional ripple animation
                                    value < 1.0
                                        ? CircularProgressIndicator(
                                            value: value * 0.95,
                                            strokeWidth: 4,
                                            valueColor: AlwaysStoppedAnimation<
                                                    Color>(
                                                Colors.green.withOpacity(0.7)),
                                            strokeCap: StrokeCap.round,
                                          )
                                        : Container(),
                                  ],
                                );
                              },
                            ),
                            // Inner white circle for better contrast
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            // Additional animation for loading effect
                            TweenAnimationBuilder(
                              tween: Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ),
                              duration: const Duration(milliseconds: 2500),
                              builder: (context, double loadValue, _) {
                                final accValue = double.tryParse(
                                            accuracy.replaceAll('%', '')) !=
                                        null
                                    ? double.parse(
                                            accuracy.replaceAll('%', '')) /
                                        100
                                    : 0.0;

                                return AnimatedBuilder(
                                  animation: _popupAnimationController,
                                  builder: (context, _) {
                                    return SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: CustomPaint(
                                        painter: LoadingPainter(
                                          progress: accValue * loadValue,
                                          color: Colors.green.withOpacity(0.15),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            // Percentage text with dynamic style
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  accuracy,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: double.tryParse(accuracy.replaceAll(
                                                    '%', '')) !=
                                                null &&
                                            double.parse(accuracy.replaceAll(
                                                    '%', '')) >
                                                50
                                        ? Colors.green.shade700
                                        : double.parse(accuracy.replaceAll(
                                                    '%', '')) >
                                                30
                                            ? Colors.orange.shade700
                                            : Colors.red.shade700,
                                  ),
                                ),
                                Text(
                                  'Accuracy',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            // Checkmark if 100%
                            if (accuracy == "100%" || accuracy == "100")
                              Positioned(
                                top: 20,
                                right: 30,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade500,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Display sources only once, if available - MODIFIED THIS PART
                      if (_verificationMessage.contains('Sources:')) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    color: Colors.green.shade600,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Sources:",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // This is the modified part to display each source on a new line
                              ..._verificationMessage
                                  .split('Sources:')
                                  .last
                                  .trim()
                                  .split(',')
                                  .map((source) => source.trim())
                                  .where((source) => source.isNotEmpty)
                                  .map((source) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green.shade500,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                source,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  height: 1.4,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ] else ...[
                      ResultIconWidget(
                        isVerified: isRelated,
                        controller: _popupAnimationController,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Attention!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 239, 64, 0),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _verificationMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRelated
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: isRelated
                            ? Colors.green.withOpacity(0.5)
                            : Colors.orange.withOpacity(0.5),
                      ),
                      child: const Text(
                        'Compris',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> startScraping() async {
    String info = _textController.text;
    final url =
        Uri.parse('${Config.baseUrl}/scraper/start?info=$info');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print("Scraping completed successfully");
        print(response.body);
        print("-------------------------");
        print(jsonDecode(response.body) as Map<String, dynamic>);
        print("--------- END OF SCRAPPING ----------------");
        print("--------- END OF SCRAPPING ----------------");
        print("--------- END OF SCRAPPING ----------------");
        // Parse the JSON response
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print("Failed to complete scraping: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error during scraping: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(Color(0xFFE3F2FD), Color(0xFFE1F5FE),
                          _backgroundController.value) ??
                      Color(0xFFE3F2FD),
                  Colors.white,
                  Color.lerp(Color(0xFFE1F5FE), Color(0xFFE8F5E9),
                          _backgroundController.value) ??
                      Color(0xFFE1F5FE),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // En-tête avec animation
              Container(
                height: 200,
                margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Color(0xFFE3F2FD),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.15),
                      blurRadius: 25,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Éléments de design fixes
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      left: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Icônes flottantes animées
                    ...List.generate(5, (index) {
                      return FloatingIconWidget(
                        controller: _floatingIconControllers[index],
                        index: index,
                        icon: _getMedicalIcon(index),
                        screenWidth: MediaQuery.of(context).size.width -
                            32, // Largeur de l'écran moins les marges
                      );
                    }),

                    // Logo central
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color(0xFF0A6EB4),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF0A6EB4).withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),

                    // Contenu principal de l'en-tête
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 30),
                          const Text(
                            'Vérificateur d\'Informations Médicales',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A6EB4),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 50,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Color(0xFF0A6EB4).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Vérifiez la fiabilité de vos informations médicales',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Formulaire
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Champ de texte pour la question médicale
                      Row(
                        children: [
                          Icon(
                            Icons.medical_information,
                            color: Color(0xFF0A6EB4),
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Information ou question médicale:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A6EB4),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildElevatedTextField(
                        controller: _textController,
                        hintText:
                            'Saisissez votre information ou question médicale...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 28),

                      // Champ de texte pour l'URL
                      Row(
                        children: [
                          Icon(
                            Icons.link,
                            color: Color(0xFF0A6EB4),
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'URL à vérifier:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A6EB4),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildElevatedTextField(
                        controller: _urlController,
                        hintText: 'https://',
                        prefixIcon: Icons.public,
                      ),
                      const SizedBox(height: 38),

                      // Bouton de vérification avec animation - CORRIGÉ ICI
                      // Bouton de vérification avec animation - CORRIGÉ ICI
// Bouton de vérification avec animation - CORRIGÉ
                      AnimatedBuilder(
                        animation: _buttonAnimationController,
                        builder: (context, child) {
                          return Container(
                            width: double.infinity,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF0A6EB4).withOpacity(0.2 +
                                      0.1 * _buttonAnimationController.value),
                                  blurRadius:
                                      12 + 8 * _buttonAnimationController.value,
                                  spreadRadius:
                                      2 + _buttonAnimationController.value,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: (_isVerifying ||
                                      (_urlController.text.isEmpty &&
                                          _textController.text.isEmpty) ||
                                      (_urlController.text.isNotEmpty &&
                                          _textController.text.isNotEmpty))
                                  ? null
                                  : () {
                                      if (_urlController.text.isNotEmpty &&
                                          _textController.text.isEmpty) {
                                        final url = _urlController.text.trim();
                                        if (!Uri.parse(url).isAbsolute ||
                                            !url.startsWith('http')) {
                                          setState(() {
                                            _verificationMessage =
                                                'URL invalide. Veuillez entrer une URL complète commençant par http:// ou https://';
                                          });
                                          _showVerificationResult(false);
                                        } else {
                                          _verifyImage();
                                        }
                                      } else if (_textController
                                              .text.isNotEmpty &&
                                          _urlController.text.isEmpty) {
                                        _verifyInformation();
                                      } else if (_textController
                                              .text.isNotEmpty &&
                                          _urlController.text.isNotEmpty) {
                                        setState(() {
                                          _verificationMessage =
                                              'Veuillez ne remplir qu\'un seul champ (texte ou URL).';
                                        });
                                        _showVerificationResult(false);
                                      } else {
                                        setState(() {
                                          _verificationMessage =
                                              'Veuillez remplir au moins un champ.';
                                        });
                                        _showVerificationResult(false);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0A6EB4),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                disabledBackgroundColor: Color(0xFF0A6EB4)
                                    .withOpacity(
                                        0.6), // Couleur plus claire quand désactivé
                              ),
                              child: _isVerifying
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Analyse en cours...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        // Effet de lumière animé sur le bouton
                                        Positioned.fill(
                                          child: Transform.translate(
                                            offset: Offset(
                                                _buttonAnimationController
                                                            .value *
                                                        300 -
                                                    150,
                                                0),
                                            child: Container(
                                              width: 60,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(0),
                                                    Colors.white
                                                        .withOpacity(0.2),
                                                    Colors.white.withOpacity(0),
                                                  ],
                                                  stops: [0.0, 0.5, 1.0],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Contenu du bouton
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.search,
                                                    color: Colors.white,
                                                    size: 24),
                                              ),
                                              const SizedBox(width: 16),
                                              const Text(
                                                'Vérifier cette information',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

// Information supplémentaire
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.shade100,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF0A6EB4),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Notre système utilise l\'intelligence artificielle pour analyser la fiabilité des informations médicales',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(20),
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Icon(prefixIcon,
                      color: Color(0xFF0A6EB4).withOpacity(0.7)),
                )
              : null,
          prefixIconConstraints: BoxConstraints(minWidth: 60),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.blue.shade50,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Color(0xFF0A6EB4),
              width: 1.5,
            ),
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  IconData _getMedicalIcon(int index) {
    List<IconData> medicalIcons = [
      Icons.medical_services,
      Icons.health_and_safety,
      Icons.healing,
      Icons.medication,
      Icons.local_hospital,
    ];
    return medicalIcons[index % medicalIcons.length];
  }
}

class LoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  LoadingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dessine le remplissage vert jusqu'à la hauteur correspondant au pourcentage
    final fillHeight = size.height * progress;
    final rect =
        Rect.fromLTWH(0, size.height - fillHeight, size.width, fillHeight);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Créer un chemin circulaire pour clipper le rectangle
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    canvas.clipPath(clipPath);
    canvas.drawRect(rect, paint);

    // Ajouter des ondes pour un effet dynamique
    final wavePaint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final now = DateTime.now().millisecondsSinceEpoch / 300;
    final waveHeight = size.height * 0.05;

    for (var i = 0; i < 3; i++) {
      final wavePath = Path();
      final offset = i * 0.3;

      wavePath.moveTo(0, size.height - fillHeight - waveHeight);

      for (var x = 0.0; x < size.width; x += 5) {
        final y = sin((x / size.width * 2 * pi) + now + offset) * waveHeight;
        wavePath.lineTo(x, size.height - fillHeight + y);
      }

      wavePath.lineTo(size.width, size.height);
      wavePath.lineTo(0, size.height);
      wavePath.close();

      canvas.drawPath(wavePath, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Widget amélioré pour les icônes flottantes avec contrôle de position
class FloatingIconWidget extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final IconData icon;
  final double screenWidth;

  const FloatingIconWidget({
    Key? key,
    required this.controller,
    required this.index,
    required this.icon,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Position initiale fixe pour éviter les problèmes
    final startX = (index * 60) % (screenWidth - 40);
    final startY = 40.0 + (index * 30) % 100;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Animation de mouvement simplifiée
        final offsetX = sin(controller.value * pi * 2) * 15;
        final offsetY = cos(controller.value * pi * 2) * 15;

        return Positioned(
          left: startX + offsetX,
          top: startY + offsetY,
          child: Opacity(
            opacity: 0.3 + 0.2 * sin(controller.value * pi),
            child: Icon(
              icon,
              size: 28 + index % 10, // Taille variable mais limitée
              color: Color(0xFF0A6EB4),
            ),
          ),
        );
      },
    );
  }
}

// Widget amélioré pour l'icône de résultat
class ResultIconWidget extends StatelessWidget {
  final bool isVerified;
  final AnimationController controller;

  const ResultIconWidget({
    Key? key,
    required this.isVerified,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.forward();

    if (isVerified) {
      // Animation pour l'icône de vérification
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Transform.scale(
                scale: Curves.elasticOut.transform(controller.value),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      // Animation pour l'icône d'avertissement
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          // Animation de secousse horizontale simplifiée
          final shakeOffset =
              sin(controller.value * 8) * 6.0 * (1.0 - controller.value);

          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.warning_amber,
                      size: 60,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}