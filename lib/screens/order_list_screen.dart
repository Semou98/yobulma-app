// lib/data/mock_data.dart

enum Role { ADMIN, VENDEUR, LIVREUR }

class User {
  final String phoneNumber;
  final List<Role> roles;

  User({required this.phoneNumber, required this.roles});
}

class MockData {
  static final List<User> users = [
    User(phoneNumber: '771234567', roles: [Role.VENDEUR]),
    User(phoneNumber: '771234568', roles: [Role.LIVREUR]),
    User(phoneNumber: '771234569', roles: [Role.ADMIN]),
  ];
}