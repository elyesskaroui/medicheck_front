import 'package:json_annotation/json_annotation.dart';

part 'LoginResponse.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'accessToken')
  final String accessToken;
  
  @JsonKey(name: 'refreshToken')
  final String refreshToken;

  @JsonKey(name: 'userId')
  final String userId;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}