// lib/app_state.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'utils/enums.dart';

class AppState extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isInitialized = false;
  
  UserModel? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _loadUser(user.uid);
      }
    } catch (e) {
      debugPrint('Erreur initialisation AppState: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  Future<void> setUser(UserModel? user) async {
    _currentUser = user;
    // Ne pas notifier immédiatement, attendre la fin du build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  
  Future<void> _loadUser(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Erreur chargement utilisateur: $e');
    }
    // Ne pas notifier immédiatement
  }
  
  void logout() {
    _currentUser = null;
    // Ne pas notifier immédiatement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}