class AppConfig {
  // Configurez l'adresse IP de votre serveur ici
  static const String SERVER_IP = "169.254.57.241";
  
  // Ports des différents services
  static const int API_PORT = 3000;
  static const int ANALYSIS_PORT = 9000;
  static const int WEBSOCKET_PORT = 8080;
  
  // URLs complets pour les différents services
  static String get BASE_URL => "http://$SERVER_IP:$API_PORT/";
  static String get ANALYSIS_URL => "http://$SERVER_IP:$ANALYSIS_PORT/";
  static String get WEBSOCKET_URL => "ws://$SERVER_IP:$WEBSOCKET_PORT";
  
  // Chemins d'accès spécifiques
  static String get UPLOADS_PATH => "${BASE_URL}uploads/";
  static String get DEFAULT_PROFILE_PICTURE => "${UPLOADS_PATH}profiles/default.png";
}
