import 'package:yoboulma_app/core/enums.dart';

class User {
  final String id;
  final String phoneNumber;
  final String? email;
  final List<Role> roles; // ADMIN, VENDEUR, LIVREUR
  final String name;
  final String? adresse;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.phoneNumber,
    this.email,
    required this.roles,
    required this.name,
    this.adresse,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      roles: (json['roles'] as List).map((r) => Role.values.byName(r)).toList(),
      name: json['name'],
      adresse: json['adresse'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'email': email,
      'roles': roles.map((r) => r.name).toList(),
      'name': name,
      'adresse': adresse,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
