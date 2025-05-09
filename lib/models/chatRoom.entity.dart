import 'package:flutter_application_1/models/SignUpResponse.dart';

class ChatRoom {
  final String id;
  final List<User> users; 
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.users,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['_id'],
      users: List<User>.from(json['users']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
