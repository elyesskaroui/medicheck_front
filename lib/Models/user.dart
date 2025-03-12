class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? roleId;
  final String prenom;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.roleId,
    required this.prenom,
  });

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',          // Assuming the MongoDB _id field
      name: json['name'] ?? '',       // Ensure no null values
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      roleId: json['roleId'],
      prenom: json['prénom'] ?? '',   // Ensure no null values
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,       // Include id if needed in the payload
      'name': name,
      'email': email,
      'password': password,
      'roleId': roleId,
      'prénom': prenom,
    };
  }
}
