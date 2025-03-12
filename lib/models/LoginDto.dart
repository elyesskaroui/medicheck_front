class LoginDto {
  final String email;
  final String password;

  LoginDto({required this.email, required this.password});

  // Convert the Dart object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
