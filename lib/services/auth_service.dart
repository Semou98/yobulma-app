// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../utils/enums.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enregistrer un utilisateur
  Future<UserModel?> register({
    required String phoneNumber,
    String? email,
    required String displayName,
    required UserRole role,
    String? password,
    String? boutiqueName,
    String? vehicleType,
    String? vehicleNumber,
  }) async {
    try {
      UserCredential? userCredential;
      
      if (email != null && password != null) {
        // Création avec email/mot de passe
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // Création anonyme avec vérification par téléphone plus tard
        userCredential = await _auth.signInAnonymously();
      }

      final user = userCredential.user;
      if (user == null) throw Exception("L'utilisateur n'a pas été créé");

      // Mettre à jour le nom d'affichage si possible
      if (displayName.isNotEmpty) {
        try {
          await user.updateDisplayName(displayName);
        } catch (e) {
          debugPrint('Erreur mise à jour displayName: $e');
        }
      }
      
      // Préparer les données utilisateur
      final userData = {
        'id': user.uid,
        'phoneNumber': phoneNumber,
        'phone': phoneNumber, // Ajouté pour compatibilité
        'fullName': displayName, // Ajouté - requis par UserModel
        'email': email ?? '',
        'displayName': displayName,
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'profileCompleted': true,
      };

      // Ajouter des informations spécifiques au rôle
      if (role == UserRole.vendeur && boutiqueName != null && boutiqueName.isNotEmpty) {
        userData['boutique'] = {
          'name': boutiqueName,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        };
        userData['boutiqueName'] = boutiqueName;
      }

      if (role == UserRole.livreur) {
        userData['vehicle'] = {
          'type': vehicleType ?? '',
          'number': vehicleNumber ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        };
        if (vehicleType != null) userData['vehicleType'] = vehicleType;
        if (vehicleNumber != null) userData['vehicleNumber'] = vehicleNumber;
      }

      // Enregistrer dans Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      // Retourner le modèle utilisateur
      return UserModel(
        id: user.uid,
        phoneNumber: phoneNumber,
        fullName: displayName, // Ajouté
        phone: phoneNumber, // Ajouté
        email: email,
        displayName: displayName,
        role: role,
        boutiqueName: boutiqueName,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        profileCompleted: true,
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'inscription: $e');
      rethrow;
    }
  }

  // Stream pour écouter les changements d'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Vérifier si l'utilisateur est connecté et récupérer son profil
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
    } catch (e) {
      debugPrint('Erreur récupération utilisateur: $e');
    }
    
    return null;
  }

  // Connexion avec téléphone (OTP)
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Erreur de vérification');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // Vérifier OTP
  Future<UserModel?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) return null;
      
      // Vérifier si l'utilisateur existe dans Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
      UserModel userModel;
      
      if (!userDoc.exists) {
        // Si l'utilisateur n'existe pas, créer un profil client par défaut
        final phone = userCredential.user!.phoneNumber ?? '';
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'id': userCredential.user!.uid,
          'phoneNumber': phone,
          'phone': phone,
          'fullName': 'Client',
          'displayName': 'Client',
          'role': UserRole.client.name,
          'email': userCredential.user!.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'profileCompleted': true,
        });
        
        userModel = UserModel(
          id: userCredential.user!.uid,
          phoneNumber: phone,
          fullName: 'Client',
          phone: phone,
          email: userCredential.user!.email,
          displayName: 'Client',
          role: UserRole.client,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          profileCompleted: true,
        );
      } else {
        userModel = UserModel.fromFirestore(userDoc);
      }
      
      return userModel;
    } catch (e) {
      debugPrint('Erreur OTP: $e');
      return null;
    }
  }

  // Connexion avec email
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) return null;
      
      // Récupérer les données utilisateur
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      
      return null;
    } catch (e) {
      debugPrint('Erreur connexion email: $e');
      return null;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? phone,
    String? email,
    UserRole? role,
    String? boutiqueName,
    String? vehicleType,
    String? vehicleNumber,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) {
        updateData['displayName'] = displayName;
        updateData['fullName'] = displayName;
      }
      if (phone != null) {
        updateData['phone'] = phone;
        updateData['phoneNumber'] = phone;
      }
      if (email != null) updateData['email'] = email;
      if (role != null) updateData['role'] = role.name;
      if (boutiqueName != null) {
        updateData['boutique'] = {
          'name': boutiqueName,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        updateData['boutiqueName'] = boutiqueName;
      }
      if (vehicleType != null || vehicleNumber != null) {
        updateData['vehicle'] = {
          'type': vehicleType ?? '',
          'number': vehicleNumber ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (vehicleType != null) updateData['vehicleType'] = vehicleType;
        if (vehicleNumber != null) updateData['vehicleNumber'] = vehicleNumber;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .update(updateData);
    } catch (e) {
      debugPrint('Erreur mise à jour profil: $e');
      rethrow;
    }
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Erreur réinitialisation mot de passe: $e');
      rethrow;
    }
  }

  // Vérifier si l'email est vérifié
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Envoyer l'email de vérification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint('Erreur envoi vérification email: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Supprimer le compte
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Supprimer de Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        // Supprimer le compte auth
        await user.delete();
      }
    } catch (e) {
      debugPrint('Erreur suppression compte: $e');
      rethrow;
    }
  }

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => _auth.currentUser != null;

  // Mettre à jour l'email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
      await updateUserProfile(
        userId: _auth.currentUser!.uid,
        email: newEmail,
      );
    } catch (e) {
      debugPrint('Erreur mise à jour email: $e');
      rethrow;
    }
  }

  // Mettre à jour le mot de passe
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      debugPrint('Erreur mise à jour mot de passe: $e');
      rethrow;
    }
  }

  // Mettre à jour le numéro de téléphone
  Future<void> updatePhoneNumber({
    required String phoneNumber,
    required PhoneAuthCredential credential,
  }) async {
    try {
      await _auth.currentUser?.updatePhoneNumber(credential);
      await updateUserProfile(
        userId: _auth.currentUser!.uid,
        phone: phoneNumber,
      );
    } catch (e) {
      debugPrint('Erreur mise à jour téléphone: $e');
      rethrow;
    }
  }

  // Vérifier si le numéro de téléphone existe déjà
  Future<bool> checkPhoneNumberExists(String phoneNumber) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Erreur vérification téléphone: $e');
      return false;
    }
  }

  // Vérifier si l'email existe déjà
  Future<bool> checkEmailExists(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Erreur vérification email: $e');
      return false;
    }
  }

  // Récupérer le token d'authentification
  Future<String?> getAuthToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      debugPrint('Erreur récupération token: $e');
      return null;
    }
  }

  // Rafraîchir le token
  Future<void> refreshAuthToken() async {
    try {
      await _auth.currentUser?.getIdToken(true);
    } catch (e) {
      debugPrint('Erreur rafraîchissement token: $e');
    }
  }

  // Vérifier si l'utilisateur a un profil complet
  Future<bool> isProfileComplete(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['profileCompleted'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur vérification profil: $e');
      return false;
    }
  }
}