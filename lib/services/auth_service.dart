import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'logged_user';

  /// Sauvegarde l'objet Utilisateur complet en format JSON dans le stockage local.
  /// Cette méthode est appelée juste après l'inscription ou la connexion.
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // On convertit l'objet User en Map (toJson) puis en String JSON (jsonEncode)
      String userJson = jsonEncode(user.toJson()); 
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      print("Erreur lors de la sauvegarde utilisateur: $e");
    }
  }

  /// Récupère l'utilisateur actuellement stocké.
  /// Retourne [User] si trouvé, sinon [null].
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString(_userKey);
      
      if (userJson == null || userJson.isEmpty) return null;

      // On décode la String en Map puis on reconstruit l'objet User
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      print("Erreur lors de la récupération utilisateur: $e");
      return null;
    }
  }

  /// Vérifie rapidement si un utilisateur est déjà connecté.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  /// Supprime les données de l'utilisateur du stockage local (Déconnexion).
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userKey);
    } catch (e) {
      print("Erreur lors de la déconnexion: $e");
      return false;
    }
  }
}