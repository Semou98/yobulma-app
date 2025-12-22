import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  // Clé unique pour stocker la session utilisateur
  static const String _userKey = 'logged_user';

  /// CONNEXION (Alias de saveUser pour la sémantique)
  /// Utilisé lors de l'inscription pour connecter l'utilisateur immédiatement
  static Future<void> login(User user) async {
    await saveUser(user);
  }

  /// SAUVEGARDER l'utilisateur (Persistance locale)
  /// Transforme l'objet User en JSON pour le stocker dans SharedPreferences
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Conversion Objet -> Map -> String JSON
      final String userJson = jsonEncode(user.toJson());
      
      await prefs.setString(_userKey, userJson);
      print("Session utilisateur active : ${user.name}");
    } catch (e) {
      print("Erreur AuthService (saveUser): $e");
      rethrow; // Renvoie l'erreur pour la gérer dans l'UI (SnackBar)
    }
  }

  /// RÉCUPÉRER l'utilisateur connecté
  /// Utile pour filtrer les commandes du vendeur par son ID réel
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString(_userKey);

      if (userJson != null && userJson.isNotEmpty) {
        // Conversion String JSON -> Map -> Objet User
        return User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      print("Erreur AuthService (getUser): $e");
    }
    return null;
  }

  /// VÉRIFIER l'état de la connexion
  /// Utilisé par le Splash Screen pour décider où envoyer l'utilisateur
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  /// DÉCONNEXION
  /// Nettoie la session et oblige l'utilisateur à se reconnecter
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      print("Utilisateur déconnecté");
    } catch (e) {
      print("Erreur AuthService (logout): $e");
    }
  }
}