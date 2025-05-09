import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WHOService {
  final Dio _dio = Dio();
  final String backendUrl = 'http://localhost:3000';
  final String _historyKey = 'who_chat_history';

  // Obtenir une réponse à une question sans utiliser Gemini
  Future<String> getResponse(String prompt) async {
    try {
      // Implement local pattern matching instead of AI
      return _generatePatternBasedResponse(prompt);
    } catch (e) {
      return 'Désolé, une erreur est survenue: $e';
    }
  }

  // Génère une réponse basée sur des motifs reconnus dans la question
  String _generatePatternBasedResponse(String userQuery) {
    final normalizedQuery = userQuery.toLowerCase().trim();
    
    // Pattern spécifique au COVID-19
    final covidPattern = RegExp(r'covid|coronavirus|sars.?cov', caseSensitive: false);
    final covidSymptomsPattern = RegExp(r'(covid|coronavirus).*(symptômes|signes)', caseSensitive: false);
    final covidPreventionPattern = RegExp(r'(covid|coronavirus).*(prévenir|éviter|protection)', caseSensitive: false);
    final covidVaccinePattern = RegExp(r'(covid|coronavirus).*(vaccin|vaccination)', caseSensitive: false);
    
    // Autres patterns médicaux
    final medicationPattern = RegExp(r'médicament|pilule|dose|aspirine|ibuprofène', caseSensitive: false);
    final symptomPattern = RegExp(r'fièvre|mal|douleur|toux|rhume|grippe|fatigue', caseSensitive: false);
    final preventionPattern = RegExp(r'prévenir|éviter|empêcher|protection|vaccin', caseSensitive: false);
    final dietPattern = RegExp(r'manger|alimentation|régime|nutriment|vitamine|protéine', caseSensitive: false);
    
    // COVID-19 réponses spécifiques
    if (covidSymptomsPattern.hasMatch(normalizedQuery)) {
      return "Les symptômes courants du COVID-19 comprennent: fièvre, toux sèche, fatigue, courbatures, mal de gorge, diarrhée, conjonctivite, maux de tête, perte de l'odorat ou du goût, éruption cutanée et décoloration des doigts ou des orteils. Ces symptômes sont généralement légers et commencent progressivement. Certaines personnes infectées ne présentent que des symptômes très légers voire aucun symptôme. Si vous présentez des symptômes graves, consultez immédiatement un médecin.";
    } else if (covidPreventionPattern.hasMatch(normalizedQuery)) {
      return "Pour vous protéger contre le COVID-19, l'OMS recommande de: vous laver fréquemment les mains avec du savon ou un gel hydroalcoolique, maintenir une distance d'au moins 1 mètre avec les autres personnes, éviter les endroits bondés, éviter de toucher vos yeux, votre nez et votre bouche, porter un masque en public, et rester à la maison si vous ne vous sentez pas bien. Veillez également à vous tenir informé des dernières recommandations des autorités sanitaires locales.";
    } else if (covidVaccinePattern.hasMatch(normalizedQuery)) {
      return "La vaccination contre le COVID-19 est un moyen sûr et efficace de se protéger contre les formes graves de la maladie. L'OMS recommande la vaccination pour tous les adultes éligibles. Les vaccins approuvés ont fait l'objet d'essais rigoureux pour garantir leur sécurité. Même après la vaccination, il est important de continuer à suivre les mesures de précaution. Consultez votre autorité sanitaire locale pour connaître les recommandations spécifiques à votre région.";
    } else if (covidPattern.hasMatch(normalizedQuery)) {
      return "Le COVID-19 est une maladie infectieuse causée par le coronavirus SARS-CoV-2. La plupart des personnes infectées développeront une maladie respiratoire légère à modérée et se rétabliront sans nécessiter de traitement particulier. Les personnes âgées et celles qui ont des problèmes médicaux préexistants comme des maladies cardiovasculaires, du diabète, des maladies respiratoires chroniques ou le cancer sont plus susceptibles de développer une forme grave de la maladie. Pour toute préoccupation liée au COVID-19, consultez un professionnel de santé.";
    }
    // Autres réponses médicales générales
    else if (medicationPattern.hasMatch(normalizedQuery)) {
      return "Il est important de consulter un médecin avant de prendre des médicaments. Ne prenez que les médicaments prescrits à la dose recommandée. Si vous avez des effets secondaires, contactez immédiatement votre médecin.";
    } else if (symptomPattern.hasMatch(normalizedQuery)) {
      return "Les symptômes que vous décrivez peuvent correspondre à plusieurs conditions médicales. Je vous recommande de consulter un professionnel de santé pour un diagnostic précis. En attendant, repos, hydratation et paracétamol peuvent aider à soulager l'inconfort.";
    } else if (preventionPattern.hasMatch(normalizedQuery)) {
      return "Pour maintenir une bonne santé et prévenir les maladies, l'OMS recommande: une alimentation équilibrée, une activité physique régulière, un sommeil suffisant, éviter le tabac et limiter l'alcool, et suivre les calendriers de vaccination recommandés.";
    } else if (dietPattern.hasMatch(normalizedQuery)) {
      return "Une alimentation saine selon l'OMS comprend des fruits, des légumes, des légumineuses, des noix et des céréales complètes. Limitez le sel, le sucre et les graisses. Buvez suffisamment d'eau et pratiquez une activité physique régulière pour maintenir un poids santé.";
    } else {
      return "Je suis votre assistant médical basé sur les recommandations de l'OMS. Je peux vous fournir des informations générales sur la santé, mais n'oubliez pas que je ne remplace pas une consultation médicale. Pour des conseils spécifiques, veuillez consulter un professionnel de santé.";
    }
  }

  // Sauvegarder l'historique dans SharedPreferences (pas de backend)
   Future<void> saveHistory(List<Map<String, dynamic>> messages) async {
    try {
      // Try backend first
      try {
        await _dio.post(
          '$backendUrl/chat-history/save',
          data: {
            'messages': messages,
          },
        );
      } catch (e) {
        // Backend failed, fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_historyKey, jsonEncode(messages));
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'historique: $e');
    }
  }

  // Charger l'historique depuis SharedPreferences ou backend
  Future<List<Map<String, dynamic>>> loadHistory() async {
    try {
      // Try backend first
      try {
        final response = await _dio.get('$backendUrl/chat-history');
        if (response.data['success']) {
          final List<dynamic> history = response.data['history'] as List;
          return history.map((item) => Map<String, dynamic>.from(item)).toList();
        } else {
          throw 'Backend error';
        }
      } catch (e) {
        // Backend failed, fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        final String? data = prefs.getString(_historyKey);
        if (data != null) {
          final List<dynamic> jsonData = jsonDecode(data);
          return jsonData.cast<Map<String, dynamic>>();
        }
        return [];
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'historique: $e');
      return [];
    }
  }
  // Supprimer l'historique
  Future<void> clearHistory() async {
    try {
      // Try backend first
      try {
        await _dio.delete('$backendUrl/chat-history');
      } catch (e) {
        // Silently fail and continue with local storage
      }
      // Clear local storage too
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Erreur lors de la suppression de l\'historique: $e');
    }
  }

  // Obtenir les informations sur un indicateur de santé
  Future<Map<String, dynamic>> getHealthIndicator(String indicatorCode) async {
    try {
      final response = await _dio.get('https://ghoapi.azureedge.net/api/$indicatorCode');
      return response.data;
    } catch (e) {
      throw 'Erreur lors de la récupération des données de l\'OMS: $e';
    }
  }

  // Rechercher des indicateurs par mot-clé
  Future<List<Map<String, dynamic>>> searchIndicators(String keyword) async {
    try {
      final response = await _dio.get(
        'https://ghoapi.azureedge.net/api/Indicator',
        queryParameters: {
          r'$filter': 'contains(IndicatorName,\'$keyword\')'
        }
      );
      return List<Map<String, dynamic>>.from(response.data['value']);
    } catch (e) {
      throw 'Erreur lors de la recherche d\'indicateurs: $e';
    }
  }

  // Obtenir les données pour un pays spécifique
  Future<Map<String, dynamic>> getCountryData(String indicatorCode, String countryCode) async {
    try {
      final response = await _dio.get(
        'https://ghoapi.azureedge.net/api/$indicatorCode',
        queryParameters: {
          r'$filter': 'SpatialDim eq \'$countryCode\''
        }
      );
      return response.data;
    } catch (e) {
      throw 'Erreur lors de la récupération des données du pays: $e';
    }
  }

  // Obtenir les données pour une année spécifique
  Future<Map<String, dynamic>> getDataByYear(String indicatorCode, int year) async {
    try {
      final response = await _dio.get(
        'https://ghoapi.azureedge.net/api/$indicatorCode',
        queryParameters: {
          r'$filter': 'date(TimeDimensionBegin) ge $year-01-01 and date(TimeDimensionBegin) lt ${year+1}-01-01'
        }
      );
      return response.data;
    } catch (e) {
      throw 'Erreur lors de la récupération des données pour l\'année $year: $e';
    }
  }

  // Obtenir la liste des pays disponibles
  Future<List<Map<String, dynamic>>> getAvailableCountries() async {
    try {
      final response = await _dio.get('https://ghoapi.azureedge.net/api/DIMENSION/COUNTRY/DimensionValues');
      return List<Map<String, dynamic>>.from(response.data['value']);
    } catch (e) {
      throw 'Erreur lors de la récupération de la liste des pays: $e';
    }
  }

  // Quelques codes d'indicateurs communs
  static const String LIFE_EXPECTANCY = 'WHOSIS_000001';
  static const String MORTALITY_RATE = 'MDG_0000000001';
  static const String MATERNAL_MORTALITY = 'MDG_0000000028';
  static const String TUBERCULOSIS_INCIDENCE = 'MDG_0000000020';
}