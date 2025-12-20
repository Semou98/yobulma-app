import 'package:flutter/material.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/vendeur/orders_list_screen.dart';
import 'screens/livreur/batches_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Indispensable pour utiliser SharedPreferences avant runApp
  WidgetsFlutterBinding.ensureInitialized();

  // On récupère l'instance de la mémoire locale
  final prefs = await SharedPreferences.getInstance();
  // On cherche si un rôle a été enregistré (ex: "VENDEUR")
  final String? savedRole = prefs.getString('user_role');

  runApp(YobulmaApp(initialRole: savedRole));
}

class YobulmaApp extends StatelessWidget {
  final String? initialRole;

  const YobulmaApp({super.key, this.initialRole});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yobulma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Blanc principal
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9800), // Orange tertiaire
          primary: Colors.black, // Noir secondaire
        ),
      ),
      // Si on a un rôle en mémoire, on va direct à la page, sinon Welcome
      home: _getHome(initialRole),
    );
  }

  Widget _getHome(String? role) {
    if (role == null) return const WelcomeScreen();

    // Redirection automatique selon le rôle stocké dans le téléphone
    switch (role) {
      case 'ADMIN':
        return const AdminDashboardScreen();
      case 'VENDEUR':
        return const OrderListScreen();
      case 'LIVREUR':
        return const LivreurBatchesListScreen();
      default:
        return const WelcomeScreen();
    }
  }
}
