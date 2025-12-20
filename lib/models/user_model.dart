// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/enums.dart';

class UserModel {
  final String id;
  final String? phoneNumber; // Pour Firebase Auth
  final String fullName;  
  final String phone; // Pour l'application
  final String? email;
  final String displayName;
  final UserRole role;
  final String? boutiqueName;
  final String? vehicleType;
  final String? vehicleNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool profileCompleted;

  UserModel({
    required this.id,
    this.phoneNumber,
    required this.fullName,
    required this.phone,
    this.email,
    required this.displayName,
    required this.role,
    this.boutiqueName,
    this.vehicleType,
    this.vehicleNumber,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.profileCompleted = false,
  });

  // Convertir Map en UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: data['id'] ?? doc.id,
      phoneNumber: data['phoneNumber'] ?? data['phone'], // Gère les deux cas
      fullName: data['fullName'] ?? data['displayName'] ?? 'Utilisateur',
      phone: data['phone'] ?? data['phoneNumber'] ?? '',
      email: data['email'],
      displayName: data['displayName'] ?? 'Utilisateur',
      role: UserRole.values.firstWhere(
        (e) => e.name == (data['role'] ?? 'client'),
        orElse: () => UserRole.client,
      ),
      boutiqueName: data['boutique'] != null 
          ? (data['boutique'] is Map 
              ? (data['boutique'] as Map)['name']
              : data['boutique'].toString())
          : data['boutiqueName'],
      vehicleType: data['vehicle'] != null
          ? (data['vehicle'] is Map
              ? (data['vehicle'] as Map)['type']
              : data['vehicle'].toString())
          : data['vehicleType'],
      vehicleNumber: data['vehicle'] != null
          ? (data['vehicle'] is Map
              ? (data['vehicle'] as Map)['number']
              : data['vehicle'].toString())
          : data['vehicleNumber'],
      createdAt: data['createdAt'] != null 
          ? data['createdAt'] is Timestamp 
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.parse(data['createdAt'].toString())
          : null,
      updatedAt: data['updatedAt'] != null 
          ? data['updatedAt'] is Timestamp 
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(data['updatedAt'].toString())
          : null,
      isActive: data['isActive'] ?? true,
      profileCompleted: data['profileCompleted'] ?? false,
    );
  }

  // Convertir UserModel en Map
  Map<String, dynamic> toFirestore() {
    final map = {
      'id': id,
      'phoneNumber': phoneNumber ?? phone, // Stocke phoneNumber
      'phone': phone, // Stocke aussi phone
      'fullName': fullName,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'isActive': isActive,
      'profileCompleted': profileCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Ajoute createdAt seulement à la création
    if (createdAt != null) {
      map['createdAt'] = FieldValue.serverTimestamp();
    }

    // Gestion boutique pour vendeur
    if (boutiqueName != null && boutiqueName!.isNotEmpty) {
      map['boutique'] = {
        'name': boutiqueName,
        'updatedAt': FieldValue.serverTimestamp(),
      };
    }

    // Gestion véhicule pour livreur
    if ((vehicleType != null && vehicleType!.isNotEmpty) || 
        (vehicleNumber != null && vehicleNumber!.isNotEmpty)) {
      map['vehicle'] = {
        'type': vehicleType,
        'number': vehicleNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      };
    }

    return map;
  }

  // Mettre à jour les champs
  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    String? phone,
    String? email,
    String? displayName,
    UserRole? role,
    String? boutiqueName,
    String? vehicleType,
    String? vehicleNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? profileCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      boutiqueName: boutiqueName ?? this.boutiqueName,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }

  // Méthodes utilitaires
  bool get isVendeur => role == UserRole.vendeur;
  bool get isLivreur => role == UserRole.livreur;
  bool get isClient => role == UserRole.client;
  bool get isAdmin => role == UserRole.admin;

  // Pour l'affichage
  String get roleDisplay {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.vendeur:
        return 'Vendeur';
      case UserRole.livreur:
        return 'Livreur';
      case UserRole.client:
        return 'Client';
      default:
        return 'Utilisateur';
    }
  }

  // Format pour l'affichage
  @override
  String toString() {
    return 'UserModel{id: $id, fullName: $fullName, phone: $phone, role: $role, isActive: $isActive}';
  }

  // Comparaison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          phone == other.phone &&
          role == other.role;

  @override
  int get hashCode =>
      id.hashCode ^ fullName.hashCode ^ phone.hashCode ^ role.hashCode;
}