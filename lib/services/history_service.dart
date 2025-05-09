import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _storageKey = 'chat_history';

  Future<void> saveMessages(List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(messages));
  }

  Future<List<Map<String, dynamic>>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data == null) {
        return [];
      }
      final List<dynamic> jsonData = jsonDecode(data);
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
