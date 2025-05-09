import 'package:flutter/material.dart';

class AnalysisResult {
  final String summary;
  final Map<String, String> statistics;
  final List<String> sources;

  AnalysisResult({
    required this.summary,
    required this.statistics,
    required this.sources,
  });

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'statistics': statistics,
      'sources': sources,
    };
  }
}

class AnalysisService {
  // Liste des mots-clés liés à la santé
  final Set<String> _healthKeywords = {
    'santé', 'maladie', 'symptômes', 'traitement', 'vaccin',
    'virus', 'infection', 'cancer', 'diabète', 'covid',
    'pandémie', 'épidémie', 'prévention', 'diagnostic',
    'médical', 'clinique', 'thérapie', 'patient', 'hôpital',
    'médicament', 'vaccination', 'immunité', 'transmission'
  };

  AnalysisResult analyzeResponse(String response) {
    String summary = _generateSummary(response);
    Map<String, String> statistics = _generateStatistics(response);
    List<String> sources = _generateSources(response);

    return AnalysisResult(
      summary: summary,
      statistics: statistics,
      sources: sources,
    );
  }

  List<String> _generateSources(String text) {
    List<String> sources = [];
    
    // Vérifier si le texte concerne la santé
    bool isHealthRelated = _isHealthRelated(text.toLowerCase());
    
    if (isHealthRelated) {
      // Ajouter des sources OMS pertinentes
      sources.add(_getWHOSource(text));
    }

    // Rechercher des références spécifiques dans le texte
    sources.addAll(_extractSpecificSources(text));

    // Limiter à 3 sources maximum
    if (sources.length > 3) {
      sources = sources.sublist(0, 3);
    }

    return sources;
  }

  bool _isHealthRelated(String text) {
    return _healthKeywords.any((keyword) => text.contains(keyword));
  }

  String _getWHOSource(String text) {
    // Extraire les principaux thèmes de santé du texte
    List<String> topics = _extractMainThemes(text)
        .split(', ')
        .where((topic) => topic.isNotEmpty)
        .toList();

    if (topics.isEmpty) {
      return 'Organisation mondiale de la Santé (OMS) - www.who.int/fr';
    }

    // Mapper les thèmes aux sections pertinentes de l'OMS
    Map<String, String> whoSections = {
      'covid': 'Coronavirus (COVID-19)',
      'vaccin': 'Vaccination',
      'cancer': 'Cancer',
      'diabète': 'Diabète',
      'santé': 'Thèmes de santé',
      'maladie': 'Maladies',
      'virus': 'Maladies infectieuses',
      'infection': 'Maladies infectieuses',
      'pandémie': 'Situations d\'urgence sanitaire',
      'épidémie': 'Situations d\'urgence sanitaire',
    };

    // Trouver la section OMS la plus pertinente
    for (var topic in topics) {
      for (var entry in whoSections.entries) {
        if (topic.toLowerCase().contains(entry.key)) {
          return 'OMS - ${entry.value} - www.who.int/fr/health-topics/${entry.key}';
        }
      }
    }

    return 'Organisation mondiale de la Santé (OMS) - www.who.int/fr';
  }

  List<String> _extractSpecificSources(String text) {
    List<String> sources = [];

    // Rechercher des références à des organisations avec années
    final orgRegex = RegExp(
      r'(OMS|WHO|Organisation mondiale de la [sS]anté|UNICEF|CDC|Institut|Centre|Ministère)'
      r'[^.!?]*(19|20)\d{2}[^.!?]*[.!?]'
    );
    
    final orgMatches = orgRegex.allMatches(text);
    for (var match in orgMatches) {
      String source = match.group(0)!.trim();
      if (!sources.contains(source)) {
        sources.add(source);
      }
    }

    // Rechercher des références à des études ou rapports
    final studyRegex = RegExp(
      r'(étude|rapport|recherche|analyse|publication)'
      r'[^.!?]*(19|20)\d{2}[^.!?]*[.!?]',
      caseSensitive: false
    );
    
    final studyMatches = studyRegex.allMatches(text);
    for (var match in studyMatches) {
      String source = match.group(0)!.trim();
      if (!sources.contains(source)) {
        sources.add(source);
      }
    }

    return sources;
  }

  String _generateSummary(String text) {
    // Diviser le texte en phrases
    List<String> sentences = text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).toList();
    if (sentences.isEmpty) return "Pas de résumé disponible.";
    
    // Identifier les phrases clés
    List<_ScoredSentence> scoredSentences = sentences.map((sentence) {
      int score = _calculateSentenceScore(sentence);
      return _ScoredSentence(sentence, score);
    }).toList();
    
    // Trier par score et prendre la meilleure phrase
    scoredSentences.sort((a, b) => b.score.compareTo(a.score));
    String mainSentence = scoredSentences.first.sentence;
    
    // Limiter la longueur du résumé
    if (mainSentence.length > 100) {
      mainSentence = mainSentence.substring(0, 97) + '...';
    }
    
    return mainSentence.trim() + '.';
  }

  int _calculateSentenceScore(String sentence) {
    int score = 0;
    // Mots clés importants
    final keyPhrases = [
      'important', 'essentiel', 'crucial', 'principalement',
      'notamment', 'particulièrement', 'en résumé', 'bref',
      'conclusion', 'finalement', 'donc'
    ];
    
    for (var phrase in keyPhrases) {
      if (sentence.toLowerCase().contains(phrase)) {
        score += 2;
      }
    }
    
    // Longueur optimale (entre 50 et 100 caractères)
    if (sentence.length >= 50 && sentence.length <= 100) {
      score += 3;
    }
    
    return score;
  }

  Map<String, String> _generateStatistics(String text) {
    return {
      'Thèmes principaux': _extractMainThemes(text),
      'Niveau de confiance': _calculateConfidenceLevel(text),
      'Type de réponse': _determineResponseType(text),
    };
  }

  String _extractMainThemes(String text) {
    // Identifier les mots-clés les plus fréquents
    final words = text.toLowerCase().split(RegExp(r'\s+'))
      ..removeWhere((word) => word.length < 4 || _isStopWord(word));
    
    final wordCount = <String, int>{};
    for (var word in words) {
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }
    
    final themes = wordCount.entries
      .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return themes.take(3).map((e) => e.key).join(', ');
  }

  String _calculateConfidenceLevel(String text) {
    final uncertaintyPhrases = [
      'peut-être', 'possible', 'probablement', 'pourrait',
      'je pense', 'il semble', 'il paraît'
    ];
    
    final certaintyPhrases = [
      'certainement', 'assurément', 'sans doute', 'clairement',
      'évidemment', 'en effet', 'effectivement'
    ];
    
    int uncertainCount = uncertaintyPhrases
        .where((phrase) => text.toLowerCase().contains(phrase))
        .length;
    int certainCount = certaintyPhrases
        .where((phrase) => text.toLowerCase().contains(phrase))
        .length;
    
    if (certainCount > uncertainCount) return "Élevé";
    if (uncertainCount > certainCount) return "Modéré";
    return "Normal";
  }

  String _determineResponseType(String text) {
    if (text.contains('?')) return "Question";
    if (text.contains('!')) return "Affirmation forte";
    if (text.length < 100) return "Réponse courte";
    if (text.length > 500) return "Réponse détaillée";
    return "Réponse standard";
  }

  bool _isStopWord(String word) {
    final stopWords = {
      'le', 'la', 'les', 'un', 'une', 'des', 'ce', 'ces',
      'et', 'ou', 'mais', 'donc', 'car', 'pour', 'dans',
      'sur', 'avec', 'sans', 'qui', 'que', 'quoi', 'dont',
      'où', 'quand', 'comment', 'pourquoi'
    };
    return stopWords.contains(word);
  }

  List<String> _extractTopics(String text) {
    // Mots-clés de santé communs à ignorer
    final commonWords = {
      'santé', 'maladie', 'traitement', 'symptômes', 'patient',
      'médical', 'clinique', 'hôpital', 'docteur', 'médicament'
    };
    
    // Extraire les mots uniques
    final words = text.toLowerCase()
        .split(RegExp(r'[^a-zà-ÿ]+'))
        .where((word) => word.length > 3)
        .where((word) => !commonWords.contains(word))
        .toList();
    
    // Compter la fréquence des mots
    final wordCount = <String, int>{};
    for (var word in words) {
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }
    
    // Prendre les mots les plus fréquents
    final sortedWords = wordCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedWords.take(3).map((e) => e.key).toList();
  }

  String _generateContextualSource(List<String> topics) {
    if (topics.isEmpty) {
      return "Données de l'OMS sur la santé globale";
    }

    final sourceTemplates = [
      "Rapport de l'OMS sur #TOPIC# (dernières données disponibles)",
      "Étude de l'Institut de Santé sur #TOPIC#",
      "Données du Centre de Recherche en Santé concernant #TOPIC#",
      "Statistiques de l'OMS relatives à #TOPIC#",
      "Recommandations officielles de l'OMS sur #TOPIC#"
    ];

    final random = DateTime.now().millisecondsSinceEpoch % sourceTemplates.length;
    return sourceTemplates[random].replaceAll('#TOPIC#', topics.first);
  }
}

class _ScoredSentence {
  final String sentence;
  final int score;

  _ScoredSentence(this.sentence, this.score);
}
