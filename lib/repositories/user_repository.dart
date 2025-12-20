// repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yoboulma_app/utils/enums.dart';
import '../models/user_model.dart';

// lib/repositories/user_repository.dart
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer l'utilisateur avec son rôle
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  // Mettre à jour le rôle d'un utilisateur
  Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating user role: $e');
      rethrow;
    }
  }

  // Créer un utilisateur dans Firestore
  Future<void> createUser({
  required String userId,
  required String email,
  required String phone,
  required String fullName,
  required String displayName,
  required UserRole role,
  String? boutiqueName,
  String? vehicleType,
  String? vehicleNumber,
  String? fcmToken,
}) async {
  try {
    final user = UserModel(
      id: userId,
      phoneNumber: phone, // Pour Firebase Auth
      fullName: fullName,
      phone: phone, // Pour l'application
      email: email,
      displayName: displayName,
      role: role,
      boutiqueName: boutiqueName,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      profileCompleted: true, // Le profil est complet à la création
    );

    await _firestore.collection('users').doc(userId).set(user.toFirestore());
  } catch (e) {
    debugPrint('Error creating user: $e');
    rethrow;
  }
}

}