// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SignUpResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUpResponse _$SignUpResponseFromJson(Map<String, dynamic> json) =>
    SignUpResponse(
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SignUpResponseToJson(SignUpResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'user': instance.user,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'profilePicture': instance.profilePicture,
    };
