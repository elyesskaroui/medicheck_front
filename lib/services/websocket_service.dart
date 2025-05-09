import 'dart:convert';
import 'package:flutter_application_1/config/app-config.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
class MessageResult {
  final String id;
  final UserResult user;
  final String message;
  final DateTime date;
final bool isImage;
  MessageResult({
    required this.id,
    required this.user,
    required this.message,
    required this.date,
required this.isImage,
  });

  // Factory method to create an instance from JSON
  factory MessageResult.fromJson(Map<String, dynamic> json) {
    return MessageResult(
      id: json['_id'],
      user: UserResult.fromJson(json['sender_id']),
      message: json['message'],
      date: DateTime.parse(json['date']),
      isImage: json['isImage'] ,
    );
  }
}

class UserResult {
  final String id;
  final String name;
  final String email;
  final String profilePicture;
  final DateTime? bannedUntil;
  UserResult({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    this.bannedUntil,
  });

  factory UserResult.fromJson(Map<String, dynamic> json) {
    return UserResult(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profilePicture'] ?? '',
      bannedUntil: json['bannedUntil'] != null
          ? DateTime.parse(json['bannedUntil'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'bannedUntil': bannedUntil?.toIso8601String(),
    };
  }
}

class Message {
  final String message;
  final String senderId;
  final DateTime date;
  final bool isImage;
  Message({
    required this.message,
    required this.senderId,
    required this.date,
    required this.isImage,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'],
      senderId: json['sender'],
      date: DateTime.parse(json['date']),
      isImage: json['isImage'] ?? false, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sender_id': senderId,
      'date': date.toIso8601String(),
      'isImage': isImage,
    };
  }
}

class WebSocketService {
  late WebSocketChannel channel;

  void connect() {
    // Utilisation de l'URL centralisée de AppConfig
    channel = IOWebSocketChannel.connect(AppConfig.WEBSOCKET_URL);
    print('✅ Connected to WebSocket at ${AppConfig.WEBSOCKET_URL}');
  }

  void getInitData() {
    final data = jsonEncode({
      "message": {"type": "init"}
    });
    channel.sink.add(data);
    print('📤 Sent: $data');
  }

  void sendMessage(Message message) {
    final data = jsonEncode({
      "message": {"type": "message", "content": message.toJson()}
    });
    channel.sink.add(data);
    print('📤 Sent: $data');
  }

  void deleteMessage(String messageId) {
    final data = jsonEncode({
      "message": {"type": "delete", "content": messageId}
    });
    channel.sink.add(data);
    print('📤 Sent: $data');
  }

  void listenMessages(Function(String, MessageResult) onMessage) {
    channel.stream.listen(
      (message) {
        print('📥 Received: $message');
        try {
          final decodedMessage = jsonDecode(message);
          String type = decodedMessage["type"];
          if (type == "init") {
            if (decodedMessage["content"] is List) {
              for (var item in (decodedMessage["content"] as List)) {
                print(item);
                MessageResult msg = MessageResult.fromJson((item));
                onMessage("m", msg);
              }
            }
            return;
          }
          if (type == "message") {
            Map<String, dynamic> content = decodedMessage["content"];
            onMessage("m", MessageResult.fromJson(content));
            return;
          }

          if (type == "delete") {
            Map<String, dynamic> content = decodedMessage["content"];
            onMessage("d", MessageResult.fromJson(content));
            return;
          }
          if (type == "update") {
            Map<String, dynamic> content = decodedMessage["content"];
            onMessage("u", MessageResult.fromJson(content));
            return;
          }
        } catch (e) {
          print('❌ JSON Parsing Error: $e');
        }
      },
      onError: (error) => print('❌ WebSocket Error: $error'),
      onDone: () => print('❌ WebSocket Disconnected'),
    );
  }

  void disconnect() {
    channel.sink.close();
    print('❌ WebSocket Connection Closed');
  }

  void editMessage(String messageId, String newMessage) {
    final data = jsonEncode({
      "message": {
        "type": "update",
        "content": {"id": messageId, "message": newMessage}
      }
    });
    channel.sink.add(data);
  }

  void reportMessage(String myId, String messageId) {
    final data = jsonEncode({
      "message": {
        "type": "report",
        "content": {"reported_msg": messageId, "reported_user": myId}
      }
    });
    channel.sink.add(data);
  }

  Future<String> translateText(String text, String targetLang,
      {String sourceLang = 'auto'}) async {
    final url = Uri.parse('https://translate.googleapis.com/translate_a/single?'
        'client=gtx&'
        'sl=$sourceLang&'
        'tl=$targetLang&'
        'dt=t&'
        'q=${Uri.encodeComponent(text)}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[0][0][0]; 
    } else {
      throw Exception('Failed to translate: ${response.reasonPhrase}');
    }
  }

 Future<String> summarizeConversationWithCohere(
    List<String> conversation, String apiKey) async {
  final url = Uri.parse('https://api.cohere.ai/v1/summarize');

  String inputText = conversation.join('\n');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'text': inputText,
      'length': 'short', 
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['summary'] ?? 'No summary found.';
  } else {
    throw Exception('Failed to summarize conversation: ${response.body}');
  }
}
}