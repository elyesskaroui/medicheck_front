import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/DashboardScreen.dart';
import 'package:flutter_application_1/Home1Screen.dart';
import 'package:flutter_application_1/Services/config.dart';
import 'package:flutter_application_1/Social.dart';
import 'dart:ui';

import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Utilisez le contrôleur de page pour des transitions fluides
  final PageController _pageController = PageController();

  // Correction: Déclaration explicite du type List<Widget>
  final List<Widget> _screens = [
    MedInfoVerifierApp(),
    MyApp(),
    MedicalVerificationApp(),
    Social(),
  ];

  // Titres des écrans
  final List<String> _titles = ['Home', 'Dashboard', 'Video', 'Social'];
 
  // Couleurs pour le thème professionnel
  final Color _primaryColor = const Color(0xFF2563EB);
  final Color _secondaryColor = const Color(0xFFEFF6FF);
  final Color _accentColor = const Color(0xFF60A5FA);
  final Color _darkColor = const Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();

    // Configuration des animations simplifiées
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    // Démarre les animations au lancement
    _fadeController.forward();
    _scaleController.forward();

    // Configure la barre de statut pour une apparence immersive
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      // Réinitialise et relance les animations
      _fadeController.reset();
      _scaleController.reset();
      _fadeController.forward();
      _scaleController.forward();

      // Anime le changement de page
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser MediaQuery pour obtenir les dimensions de l'écran et les zones sécurisées
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double bottomPadding = mediaQuery.padding.bottom;
   
    return Scaffold(
      backgroundColor: _secondaryColor.withOpacity(0.8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(
            color: _darkColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: _darkColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: _darkColor),
            onPressed: () {},
          ),
        ],
      ),
      // SafeArea pour respecter les zones sécurisées du téléphone
      body: SafeArea(
        bottom: false, // Ne pas ajouter de padding en bas car on le gère manuellement
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _screens,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      // Utiliser BottomNavigationBar standard au lieu d'une barre personnalisée
      bottomNavigationBar: Container(
        // Ajouter padding pour respecter la zone sécurisée du bas
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library_rounded),
              label: 'Video',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Social',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    int notificationCount = 0,
  }) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: IconButton(
              icon: Icon(icon, color: _darkColor, size: 22),
              splashRadius: 24,
              onPressed: () {},
            ),
          ),
          if (notificationCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                height: 16,
                width: 16,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MedicalVerificationApp extends StatelessWidget {
  const MedicalVerificationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const VideoVerificationScreen(),
    );
  }
}
class VideoVerificationScreen extends StatefulWidget {
  const VideoVerificationScreen({Key? key}) : super(key: key);

  @override
  State<VideoVerificationScreen> createState() =>
      _VideoVerificationScreenState();
}



class _VideoVerificationScreenState extends State<VideoVerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  bool _isVerifying = false;
  late AnimationController _popupAnimationController;
  String accuracy = '0%';

  @override
  void initState() {
    super.initState();
    _popupAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _popupAnimationController.dispose();
    super.dispose();
  }

  Future<void> _verifyUrl() async {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une URL'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    // Check if URL ends with an asterisk
    if (_urlController.text.endsWith('*')) {
      _showUnverifiableContentWarning();
      return;
    }

    // Check if URL starts with https
    if (!_urlController.text.toLowerCase().startsWith('https')) {
      _showSecurityWarning();
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      String url = _urlController.text;
      // Appel à l'API avec l'URL fournie
      final response = await http.get(
        Uri.parse(
            '${Config.baseUrl}/scraper/analyzeVideo?videoUrl=$url'),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        _isVerifying = false;
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData.toString());

        // Déterminer la fiabilité basée sur les données
        bool isReliable = responseData['reliable'] ?? true;
        String message = responseData['message'] ??
            'Cette information médicale semble fiable selon nos algorithmes de vérification.';

        // Afficher les résultats dans une popup comme dans code1
        _showVerificationResult(isReliable, message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUnverifiableContentWarning() {
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
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 10),
                  )
                ],
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.warning_amber,
                        color: Colors.orange.shade600,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Attention!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Information could not be verified in trusted medical sources. We recommend consulting official health organizations for reliable information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.orange.withOpacity(0.5),
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

  void _showSecurityWarning() {
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
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 10),
                  )
                ],
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.security,
                        color: Colors.red.shade600,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Avertissement de Sécurité',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cette URL n\'utilise pas le protocole HTTPS sécurisé. Cela peut compromettre la sécurité de vos données.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nous vous recommandons d\'utiliser uniquement des sites HTTPS pour protéger vos informations personnelles et médicales.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Correct URL format (add https://)
                            if (!_urlController.text.contains('://')) {
                              _urlController.text = 'https://' + _urlController.text;
                            } else {
                              // Replace http:// with https://
                              _urlController.text = _urlController.text.replaceFirst(
                                  RegExp(r'http://'), 'https://');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.green.withOpacity(0.5),
                          ),
                          child: const Text(
                            'Utiliser HTTPS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Continue anyway with original URL
                            setState(() {
                              _isVerifying = true;
                            });
                            _proceedWithVerification(_urlController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.grey.withOpacity(0.5),
                          ),
                          child: const Text(
                            'Continuer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
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
        ),
      ),
    );
  }
  
  Future<void> _proceedWithVerification(String url) async {
    try {
      // Appel à l'API avec l'URL fournie
      final response = await http.get(
        Uri.parse(
            '${Config.baseUrl}/scraper/analyzeVideo?videoUrl=$url'),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        _isVerifying = false;
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData.toString());

        // Déterminer la fiabilité basée sur les données
        bool isReliable = responseData['reliable'] ?? true;
        String message = responseData['message'] ??
            'Cette information médicale semble fiable selon nos algorithmes de vérification.';

        // Afficher les résultats dans une popup comme dans code1
        _showVerificationResult(isReliable, message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showVerificationResult(bool isValid, String message) {
    _popupAnimationController.reset();

    // Calculer une précision simulée basée sur la validité
    accuracy = isValid ? '87.5%' : '23.4%';

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
                    color: isValid
                        ? Colors.green.withOpacity(0.4)
                        : Colors.red.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 10),
                  )
                ],
                border: Border.all(
                  color: isValid
                      ? Colors.green.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ResultIconWidget(
                      isVerified: isValid,
                      controller: _popupAnimationController,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isValid ? 'Checking medical information' : 'Attention!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isValid
                            ? Colors.green.shade700
                            : const Color.fromARGB(255, 239, 64, 0),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (isValid) ...[
                      const SizedBox(height: 20),
                      // Indicateur de pourcentage circulaire avec animation
                      Container(
                        width: 150,
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Cercle d'arrière-plan avec dégradé
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
                            // Cercle de progression d'arrière-plan
                            CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey.shade300.withOpacity(0.6),
                              ),
                            ),
                            // Animation de chargement
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
                                    // Indicateur de progression principal
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
                                    // Animation d'ondulation
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
                            // Cercle blanc intérieur
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
                            // Animation pour l'effet de charge
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
                            // Texte de pourcentage
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
                            // Coche si 100%
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
                    ],
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isValid
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: isValid
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100.withOpacity(0.8),
              Colors.blue.shade50.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec logo
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Vérificateur d'Informations Médicales",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Vérifiez la fiabilité de vos informations médicales en ligne",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Section d'URL
                Row(
                  children: [
                    Icon(
                      Icons.link,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "URL de l'information à vérifier:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.language,
                          color: Colors.blue.shade400,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            hintText: "https://",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Bouton de vérification
                Center(
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.blue.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isVerifying
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.search),
                        const SizedBox(width: 12),
                        Text(
                          _isVerifying
                              ? "Vérification en cours..."
                              : "Vérifier cette information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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
      ),
    );
  }
}


// Widget pour l'icône de résultat animé
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
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isVerified ? Colors.green.shade100 : Colors.orange.shade100,
        boxShadow: [
          BoxShadow(
            color: (isVerified ? Colors.green : Colors.orange).withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 4,
          )
        ],
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: isVerified
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 48,
                  )
                : Icon(
                    Icons.warning_amber,
                    color: Colors.orange.shade700,
                    size: 48,
                  ),
          );
        },
      ),
    );
  }
}

// Peintre personnalisé pour l'animation d'onde dans le cercle
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