import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  // Clé unique pour stocker la chaîne JSON dans le téléphone
  static const String _userKey = 'logged_user';

  /// SAUVEGARDER l'utilisateur (Inscription ou Connexion)
  /// Cette méthode transforme l'objet User en texte JSON pour SharedPreferences
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Conversion de l'objet User en Map, puis en String JSON
      final String userJson = jsonEncode(user.toJson());
      
      // Stockage permanent sur le disque local
      await prefs.setString(_userKey, userJson);
      print("Utilisateur sauvegardé avec succès en JSON");
    } catch (e) {
      print("Erreur lors de la sauvegarde de l'utilisateur: $e");
    }
  }

  /// RÉCUPÉRER l'utilisateur (Vérification au démarrage)
  /// Lit la chaîne JSON et la retransforme en objet User exploitable par Flutter
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString(_userKey);

      if (userJson != null && userJson.isNotEmpty) {
        // Décodage du String vers Map, puis Map vers objet User
        return User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur: $e");
    }
    return null;
  }

  /// VÉRIFIER si un utilisateur est déjà connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  /// DÉCONNEXION
  /// Supprime le fichier JSON virtuel de la mémoire
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    print("Session utilisateur supprimée");
  }
}