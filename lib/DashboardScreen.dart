import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
      title: 'Vérificateur Médical',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardScreen(),
    );
  }
}

// Service pour récupérer les statistiques
class StatsService {
  final String baseUrl = 'http://192.168.122.40:3000/scraper';

  Future<Map<String, dynamic>> getVerificationStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      // Return default values if API call fails
      return {
        'todayVerifications': {'count': 0, 'change': 0, 'isPositive': true},
        'averageReliability': {'percentage': 0, 'change': 0, 'isPositive': true}
      };
    }
  }
}

// Écran principal du tableau de bord
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StatsService _statsService = StatsService();
  Map<String, dynamic> _stats = {
    'todayVerifications': {'count': 0, 'change': 0, 'isPositive': true},
    'averageReliability': {'percentage': 0, 'change': 0, 'isPositive': true}
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _statsService.getVerificationStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tableau de bord',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vérification des informations médicales',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  radius: 20,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      buildMainStatCard1(
                        context,
                        title: 'Vérifications aujourd\'hui',
                        value: _stats['todayVerifications']['count'].toString(),
                        changeText:
                            '${_stats['todayVerifications']['isPositive'] ? '+' : ''}${_stats['todayVerifications']['change']}% vs hier',
                        isPositive: _stats['todayVerifications']['isPositive'],
                        backgroundColor: Colors.green.withOpacity(0.2),
                      ),
                      const SizedBox(width: 16),
                      buildMainStatCard1(
                        context,
                        title: 'Fiabilité moyenne',
                        value: '${_stats['averageReliability']['percentage']}%',
                        changeText:
                            '${_stats['averageReliability']['isPositive'] ? '+' : ''}${_stats['averageReliability']['change']}% vs hier',
                        isPositive: _stats['averageReliability']['isPositive'],
                        backgroundColor: Colors.red.withOpacity(0.2),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Tendances Médicales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'IMPORTANT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildAlertCard(
                  context,
                  title: 'Faux traitement COVID',
                  subtitle: '4.5k partages',
                  color: Colors.red,
                  level: 'ALERTE CRITIQUE',
                  alertDetails: AlertDetails(
                    title: 'Faux traitement COVID',
                    level: 'ALERTE CRITIQUE',
                    color: Colors.red,
                    description:
                        'Un remède prétendu contre le COVID-19 circule sur les réseaux sociaux, prétendant guérir l\'infection en 48 heures.',
                    scientificConsensus:
                        'Aucune preuve scientifique ne soutient cette affirmation. Les traitements approuvés sont uniquement disponibles sur prescription médicale.',
                    impact: 'Très élevé - Mondial',
                    sharesCount: '4,523',
                    growthRate: '+127% en 24h',
                    sourcesList: [
                      'Facebook (62%)',
                      'Twitter (21%)',
                      'WhatsApp (17%)'
                    ],
                    relatedArticles: [
                      'Mythes et réalités sur le COVID-19',
                      'Guide des traitements approuvés'
                    ],
                    icon: Icons.coronavirus_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                _buildAlertCard(
                  context,
                  title: 'Régime anti-cancer',
                  subtitle: '1.2k partages',
                  color: Colors.orange,
                  level: 'ATTENTION',
                  alertDetails: AlertDetails(
                    title: 'Régime anti-cancer',
                    level: 'ATTENTION',
                    color: Colors.orange,
                    description:
                        'Une publication virale prétend qu\'un régime spécifique peut guérir tous les types de cancer en 30 jours sans traitement médical.',
                    scientificConsensus:
                        'Aucun régime alimentaire ne peut remplacer les traitements médicaux contre le cancer. Cette affirmation peut mettre en danger les patients qui retarderaient leurs soins médicaux.',
                    impact: 'Élevé - Europe, Amérique du Nord',
                    sharesCount: '1,247',
                    growthRate: '+43% en 24h',
                    sourcesList: [
                      'Pinterest (45%)',
                      'Instagram (32%)',
                      'TikTok (23%)'
                    ],
                    relatedArticles: [
                      'Nutrition et cancer : les vrais conseils',
                      'Comment évaluer les conseils santé en ligne'
                    ],
                    icon: Icons.no_food_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vérifications Récentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Tout voir',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildVerificationItem(
                    context,
                    title: 'Les vaccins COVID réduisent les hospitalisations',
                    status: 'CONFIRMÉ 92%',
                    isTrue: true,
                    source: 'OMS.int • Il y a 2h • 3 références scientifiques',
                    impact: 'Impact: Élevé • Mondial',
                  ),
                  const SizedBox(height: 12),
                  _buildVerificationItem(
                    context,
                    title: 'Le jus de citron guérit le cancer en 30 jours',
                    status: 'RÉFUTÉ 23%',
                    isTrue: false,
                    source: 'InfoSanté.com • Il y a 5h • 0 références',
                    impact: 'Impact: Critique • Europe, Am. Nord',
                  ),
                  const SizedBox(height: 12),
                  _buildVerificationItem(
                    context,
                    title: 'L\'activité physique améliore l\'immunité',
                    status: 'CONFIRMÉ 88%',
                    isTrue: true,
                    source:
                        'SciMed.org • Il y a 8h • 5 références scientifiques',
                    impact: 'Impact: Moyen • Global',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMainStatCard1(
    BuildContext context, {
    required String title,
    required String value,
    required String changeText,
    required bool isPositive,
    Color? backgroundColor,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          _showStatsDetailPopup(context, title, value, isPositive);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    changeText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatsDetailPopup(
      BuildContext context, String title, String value, bool isPositive) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête avec icône
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Affichage de la valeur avec effet 3D
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isPositive ? Colors.green.shade50 : Colors.red.shade50,
                        isPositive ? Colors.green.shade100 : Colors.red.shade100,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isPositive ? Colors.green : Colors.red).withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                          Text(
                            isPositive ? '+24% vs hier' : '-92% vs hier',
                            style: TextStyle(
                              fontSize: 14,
                              color: isPositive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Graphique avec icônes spécifiques
                Container(
                  height: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Icônes verticales sur le côté
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                            size: 20,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                          Icon(
                            isPositive ? Icons.done_all : Icons.error_outline,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          Icon(
                            isPositive ? Icons.verified : Icons.warning_amber,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      
                      // Graphique à barres animé avec effet 3D
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (index) {
                            // Hauteurs dynamiques basées sur la tendance
                            double baseHeight = isPositive 
                                ? 0.4 + (index * 0.08) 
                                : 0.8 - (index * 0.1);
                            
                            // Petite variation pour effet naturel
                            double randomFactor = 0.05 * (index % 3);
                            double heightFactor = baseHeight + randomFactor;
                            
                            return Container(
                              width: 24,
                              height: 120 * heightFactor,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    isPositive ? Colors.green : Colors.red,
                                    isPositive ? Colors.green.shade300 : Colors.red.shade300,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isPositive ? Colors.green : Colors.red).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Bouton de fermeture amélioré
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: isPositive ? Colors.green : Colors.red,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String changeText,
    required bool isPositive,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                changeText,
                style: TextStyle(
                  fontSize: 12,
                  color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required String level,
    required AlertDetails alertDetails,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  level == 'ALERTE CRITIQUE'
                      ? Icons.warning_amber_rounded
                      : Icons.info_outline,
                  color: color,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () {
                  _showAlertDetailsDialog(context, alertDetails);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VOIR DÉTAILS',
                        style: TextStyle(
                          fontSize: 10,
                          color: color.withOpacity(0.8),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: color.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationItem(
    BuildContext context, {
    required String title,
    required String status,
    required bool isTrue,
    required String source,
    required String impact,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isTrue ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: isTrue ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            source,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: Colors.teal,
              ),
              const SizedBox(width: 4),
              Text(
                impact,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAlertDetailsDialog(BuildContext context, AlertDetails details) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fermer',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => AlertDetailsDialog(details: details),
      transitionBuilder: (_, animation, __, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }
}

// Class to represent alert details
class AlertDetails {
  final String title;
  final String level;
  final Color color;
  final String description;
  final String scientificConsensus;
  final String impact;
  final String sharesCount;
  final String growthRate;
  final List<String> sourcesList;
  final List<String> relatedArticles;
  final IconData icon;

  AlertDetails({
    required this.title,
    required this.level,
    required this.color,
    required this.description,
    required this.scientificConsensus,
    required this.impact,
    required this.sharesCount,
    required this.growthRate,
    required this.sourcesList,
    required this.relatedArticles,
    required this.icon,
  });
}

// Nouvelle classe pour les détails d'article
class ArticleDetails {
  final String title;
  final String content;
  final List<String> keyPoints;
  final List<String> sources;
  final String author;
  final String publishDate;
  final IconData icon;
  final Color color;

  ArticleDetails({
    required this.title,
    required this.content,
    required this.keyPoints,
    required this.sources,
    required this.author,
    required this.publishDate,
    required this.icon,
    required this.color,
  });
}

// Fonction pour obtenir les détails d'un article spécifique
ArticleDetails _getArticleDetails(String articleTitle) {
  switch (articleTitle) {
    case 'Nutrition et cancer : les vrais conseils':
      return ArticleDetails(
        title: 'Nutrition et cancer : les vrais conseils',
        content:
            'L\'alimentation joue un rôle important dans le bien-être général des patients atteints de cancer. Une nutrition adéquate peut aider à gérer les symptômes du cancer et les effets secondaires des traitements, tout en améliorant la qualité de vie. Cependant, aucun régime alimentaire spécifique ne peut guérir le cancer à lui seul.\n\nLes patients doivent toujours suivre les traitements médicaux prescrits par leurs médecins. Les régimes alimentaires peuvent compléter, mais ne doivent jamais remplacer les traitements médicaux conventionnels.\n\nUne alimentation équilibrée, riche en fruits, légumes, grains entiers et protéines maigres, peut aider les patients à maintenir leur force et leur énergie pendant le traitement.',
        keyPoints: [
          'Consultez toujours votre équipe médicale avant de modifier votre alimentation',
          'Maintenez un poids santé pendant le traitement',
          'Restez hydraté en buvant beaucoup d\'eau',
          'Limitez la consommation d\'alcool',
          'Évitez les compléments alimentaires non prescrits'
        ],
        sources: [
          'Institut National du Cancer (2023)',
          'American Cancer Society (2024)',
          'Organisation Mondiale de la Santé (2023)'
        ],
        author: 'Dr. Marie Laurent',
        publishDate: '15 mars 2024',
        icon: Icons.restaurant_menu,
        color: Colors.green,
      );
    case 'Comment évaluer les conseils santé en ligne':
      return ArticleDetails(
        title: 'Comment évaluer les conseils santé en ligne',
        content:
            'Internet regorge d\'informations sur la santé, mais toutes ne sont pas fiables. Apprendre à évaluer la crédibilité des sources en ligne est une compétence essentielle pour prendre des décisions éclairées concernant votre santé.\n\nLa désinformation médicale peut avoir des conséquences graves, notamment retarder des soins médicaux nécessaires ou encourager des pratiques potentiellement dangereuses. Il est crucial de vérifier l\'exactitude des informations médicales avant de les appliquer à votre propre situation.\n\nUtilisez la méthode CRAAP pour évaluer les informations en ligne : Actualité (Currency), Pertinence (Relevance), Autorité (Authority), Exactitude (Accuracy) et Objectif (Purpose).',
        keyPoints: [
          'Vérifiez les qualifications de l\'auteur et la réputation du site',
          'Méfiez-vous des affirmations trop prometteuses ou miraculeuses',
          'Consultez plusieurs sources fiables pour vérifier l\'information',
          'Recherchez des preuves scientifiques à l\'appui des affirmations',
          'Discutez des informations trouvées avec votre professionnel de santé'
        ],
        sources: [
          'Organisation Mondiale de la Santé (2024)',
          'Haute Autorité de Santé (2023)',
          'Association Médicale Mondiale (2024)'
        ],
        author: 'Prof. Thomas Dubois',
        publishDate: '28 janvier 2024',
        icon: Icons.fact_check,
        color: Colors.blue,
      );
    case 'Mythes et réalités sur le COVID-19':
      return ArticleDetails(
        title: 'Mythes et réalités sur le COVID-19',
        content:
            'Depuis le début de la pandémie de COVID-19, de nombreux mythes et informations erronées ont circulé sur les réseaux sociaux et d\'autres plateformes. Ces mythes peuvent être dangereux s\'ils conduisent les gens à ignorer les recommandations de santé publique ou à adopter des pratiques préjudiciables.\n\nLa science du COVID-19 a évolué au fil du temps, à mesure que les chercheurs en apprenaient davantage sur le virus. Ce qui était considéré comme vrai au début de la pandémie a pu changer à la lumière de nouvelles preuves. Il est important de se tenir informé auprès de sources fiables et de suivre les directives des autorités sanitaires.',
        keyPoints: [
          'Les vaccins COVID-19 ont été rigoureusement testés pour leur sécurité et leur efficacité',
          'Les masques réduisent efficacement la transmission du virus',
          'La COVID-19 est plus grave qu\'une grippe saisonnière pour de nombreuses personnes',
          'Les antibiotiques ne traitent pas le COVID-19 car il s\'agit d\'une infection virale',
          'Les remèdes "naturels" ne peuvent pas guérir ou prévenir le COVID-19'
        ],
        sources: [
          'Organisation Mondiale de la Santé (2024)',
          'Centre Européen de Prévention et de Contrôle des Maladies (2023)',
          'Institut Pasteur (2024)'
        ],
        author: 'Dr. Sarah Cohen',
        publishDate: '10 février 2024',
        icon: Icons.coronavirus,
        color: Colors.red,
      );
    case 'Guide des traitements approuvés':
      return ArticleDetails(
        title: 'Guide des traitements approuvés pour le COVID-19',
        content:
            'Les traitements du COVID-19 ont considérablement évolué depuis le début de la pandémie. De nombreux médicaments et thérapies ont été étudiés, mais seuls certains ont démontré leur efficacité dans des essais cliniques rigoureux et ont reçu l\'autorisation des organismes réglementaires.\n\nLes traitements varient selon la gravité de la maladie, l\'âge du patient, les comorbidités et d\'autres facteurs. Il est essentiel de consulter un professionnel de la santé pour déterminer le traitement le plus approprié à votre situation.\n\nLes traitements non approuvés ou expérimentaux ne doivent être utilisés que dans le cadre d\'essais cliniques supervisés par des professionnels de la santé.',
        keyPoints: [
          'Les antiviraux peuvent réduire la durée et la gravité de la maladie s\'ils sont pris tôt',
          'Les corticostéroïdes peuvent être bénéfiques pour les cas graves nécessitant une oxygénation',
          'Les anticorps monoclonaux peuvent aider certains patients à haut risque',
          'Consultez toujours un médecin avant de prendre tout médicament',
          'La vaccination reste la meilleure protection contre les formes graves de COVID-19'
        ],
        sources: [
          'Agence Européenne des Médicaments (2024)',
          'Agence Nationale de Sécurité du Médicament (2023)',
          'National Institutes of Health (2024)'
        ],
        author: 'Dr. Philippe Martin',
        publishDate: '5 mars 2024',
        icon: Icons.medical_services,
        color: Colors.purple,
      );
    default:
      return ArticleDetails(
        title: articleTitle,
        content: 'Contenu de l\'article non disponible.',
        keyPoints: ['Information non disponible'],
        sources: ['Sources non disponibles'],
        author: 'Auteur inconnu',
        publishDate: 'Date inconnue',
        icon: Icons.help_outline,
        color: Colors.grey,
      );
  }
}

// Fonction pour afficher la boîte de dialogue d'article détaillé
void _showArticleDetailsDialog(BuildContext context, ArticleDetails article) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fermer',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => ArticleDetailsDialog(article: article),
    transitionBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuad,
          ),
        ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        ),
      );
    },
  );
}

// Custom Dialog to show alert details
class AlertDetailsDialog extends StatefulWidget {
  final AlertDetails details;

  const AlertDetailsDialog({Key? key, required this.details}) : super(key: key);

  @override
  State<AlertDetailsDialog> createState() => _AlertDetailsDialogState();
}

class _AlertDetailsDialogState extends State<AlertDetailsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.details.color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  RotationTransition(
                    turns: _iconAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.details.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.details.icon,
                        color: widget.details.color,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.details.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.details.level,
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.details.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.details.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleWithIcon(
                        Icons.description_outlined, 'Description'),
                    const SizedBox(height: 8),
                    Text(
                      widget.details.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTitleWithIcon(
                        Icons.science_outlined, 'Consensus Scientifique'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Text(
                        widget.details.scientificConsensus,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Impact',
                            widget.details.impact,
                            Icons.bar_chart_rounded,
                            Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Partages',
                            widget.details.sharesCount,
                            Icons.share_outlined,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMetricCard(
                      'Croissance',
                      widget.details.growthRate,
                      Icons.trending_up,
                      Colors.red,
                    ),
                    const SizedBox(height: 16),
                    _buildTitleWithIcon(
                        Icons.source_outlined, 'Sources de propagation'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.details.sourcesList
                          .map((source) => _buildSourceChip(source))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildTitleWithIcon(
                        Icons.article_outlined, 'Articles connexes'),
                    const SizedBox(height: 8),
                    Column(
                      children: widget.details.relatedArticles.map((article) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildRelatedArticleItem(article),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _showShareOptions(context, widget.details.title);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Partager'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Vérifier les faits'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWithIcon(IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceChip(String source) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        source,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildRelatedArticleItem(String articleTitle) {
    return InkWell(
      onTap: () {
        // Obtenir les détails de l'article correspondant
        final article = _getArticleDetails(articleTitle);
        // Afficher la boîte de dialogue d'article
        _showArticleDetailsDialog(context, article);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.article_outlined,
              size: 18,
              color: Colors.teal.shade700,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                articleTitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour afficher les options de partage
  void _showShareOptions(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ShareOptionsSheet(articleTitle: title);
      },
    );
  }
}

// Nouvelle classe pour la boîte de dialogue d'article détaillé
class ArticleDetailsDialog extends StatefulWidget {
  final ArticleDetails article;

  const ArticleDetailsDialog({Key? key, required this.article})
      : super(key: key);

  @override
  State<ArticleDetailsDialog> createState() => _ArticleDetailsDialogState();
}

class _ArticleDetailsDialogState extends State<ArticleDetailsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.article.color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  RotationTransition(
                    turns: _iconAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.article.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.article.icon,
                        color: widget.article.color,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _fadeInAnimation,
                          child: Text(
                            'ARTICLE VÉRIFIÉ',
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.article.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.article.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Article info
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  widget.article.color.withOpacity(0.2),
                              radius: 20,
                              child: Text(
                                widget.article.author.substring(0, 1),
                                style: TextStyle(
                                  color: widget.article.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.article.author,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Publié le ${widget.article.publishDate}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Article content
                      Text(
                        widget.article.content,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Key points
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.article.color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.article.color.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: widget.article.color,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'POINTS CLÉS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: widget.article.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...widget.article.keyPoints.map((point) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: widget.article.color,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          point,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sources
                      Text(
                        'Sources:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.article.sources.map((source) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• $source',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _showShareOptions(context, widget.article.title);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Partager'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.bookmark_border,
                          color: widget.article.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.article.color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour afficher les options de partage
  void _showShareOptions(BuildContext context, String articleTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ShareOptionsSheet(articleTitle: articleTitle);
      },
    );
  }
}

// Nouvelle classe pour la feuille d'options de partage
class ShareOptionsSheet extends StatefulWidget {
  final String articleTitle;

  const ShareOptionsSheet({Key? key, required this.articleTitle})
      : super(key: key);

  @override
  State<ShareOptionsSheet> createState() => _ShareOptionsSheetState();
}

class _ShareOptionsSheetState extends State<ShareOptionsSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Partager l\'article',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez comment partager "${widget.articleTitle}"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  context,
                  icon: Icons.chat_bubble_outline,
                  label: 'Message',
                  color: Colors.blue,
                ),
                _buildShareOption(
                  context,
                  icon: Icons.email_outlined,
                  label: 'Email',
                  color: Colors.red,
                ),
                _buildShareOption(
                  context,
                  icon: Icons.facebook_outlined,
                  label: 'Facebook',
                  color: Colors.indigo,
                ),
                _buildShareOption(
                  context,
                  icon: Icons.link,
                  label: 'Copier lien',
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade800,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Annuler'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        // Simuler le partage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Partage via $label en cours...'),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}