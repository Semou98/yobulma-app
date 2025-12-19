import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/enums.dart';

class UserModel {
  final String id;
  final String? email;
  final String phoneNumber;
  final String displayName;
  final UserRole role;
  final String? boutiqueName; // Pour les vendeurs
  final String? vehicleType; // Pour les livreurs (moto, voiture, etc.)
  final String? vehicleNumber; // Pour les livreurs
  final bool isActive;
  final GeoPoint? location; // Position actuelle (pour livreurs)
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.email,
    required this.phoneNumber,
    required this.displayName,
    required this.role,
    this.boutiqueName,
    this.vehicleType,
    this.vehicleNumber,
    this.isActive = true,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] as String?,
      phoneNumber: data['phoneNumber'] as String,
      displayName: data['displayName'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
        orElse: () => UserRole.client,
      ),
      boutiqueName: data['boutiqueName'] as String?,
      vehicleType: data['vehicleType'] as String?,
      vehicleNumber: data['vehicleNumber'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      location: data['location'] as GeoPoint?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'role': role.toString().split('.').last,
      'boutiqueName': boutiqueName,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'isActive': isActive,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    UserRole? role,
    String? boutiqueName,
    String? vehicleType,
    String? vehicleNumber,
    bool? isActive,
    GeoPoint? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      boutiqueName: boutiqueName ?? this.boutiqueName,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

