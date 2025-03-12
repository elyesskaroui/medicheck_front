import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageResult {
  final String id;
  final UserResult user;
  final String message;
  final DateTime date;

  MessageResult({
    required this.id,
    required this.user,
    required this.message,
    required this.date,
  });

  // Factory method to create an instance from JSON
  factory MessageResult.fromJson(Map<String, dynamic> json) {
    return MessageResult(
      id: json['_id'],
      user: UserResult.fromJson(json['sender_id']),
      message: json['message'],
      date: DateTime.parse(json['date']),
    );
  }
}

class UserResult {
  final String id;
  final String name;
  final String email;
  final String profilePicture;

  UserResult({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
  });

  factory UserResult.fromJson(Map<String, dynamic> json) {
    return UserResult(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
    };
  }
}

class Message {
  final String message;
  final String senderId;
  final DateTime date;

  Message({
    required this.message,
    required this.senderId,
    required this.date,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'],
      senderId: json['sender'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sender_id': senderId,
      'date': date.toIso8601String(),
    };
  }
}

class WebSocketService {
  late WebSocketChannel channel;

  void connect() {
    channel = IOWebSocketChannel.connect('ws://169.254.148.47:8080');
    print('✅ Connected to WebSocket');
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

//delete message
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
}