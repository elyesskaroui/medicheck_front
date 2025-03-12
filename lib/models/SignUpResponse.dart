import 'package:json_annotation/json_annotation.dart';

part 'SignUpResponse.g.dart';

@JsonSerializable()
class SignUpResponse {
  final String message;
  final User user;

  SignUpResponse({
    required this.message,
    required this.user,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) => _$SignUpResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SignUpResponseToJson(this);
}

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}