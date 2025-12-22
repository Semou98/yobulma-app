import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Imports de l'application
import 'package:yoboulma_app/chatbot_khady.dart';
import 'package:yoboulma_app/screens/auth/login_screen.dart';
import 'package:yoboulma_app/screens/auth/register_screen.dart';
import 'package:yoboulma_app/screens/auth/welcome_screen.dart';
import 'package:yoboulma_app/screens/admin/dashboard_screen.dart';
import 'package:yoboulma_app/screens/vendeur/orders_list_screen.dart';
import 'package:yoboulma_app/screens/livreur/batches_list_screen.dart';

// Services, Modèles et Enums
import 'package:yoboulma_app/services/auth_service.dart';
import 'package:yoboulma_app/models/user_model.dart';
import 'package:yoboulma_app/core/enums.dart';

void main() async {
  // Indispensable pour initialiser les plugins (SharedPreferences, Firebase, etc.)
  WidgetsFlutterBinding.ensureInitialized();

  // Fixer l'orientation de l'écran en portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 1. Récupération de la session utilisateur stockée
  User? loggedUser;
  try {
    loggedUser = await AuthService.getUser();
  } catch (e) {
    debugPrint("Erreur lors de la récupération de l'utilisateur: $e");
  }

  // 2. Lancement de l'application
  runApp(YobulmaApp(initialUser: loggedUser));
}

class YobulmaApp extends StatelessWidget {
  final User? initialUser;

  const YobulmaApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yobulma',
      debugShowCheckedModeBanner: false,

      // Configuration du thème graphique
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEE8E42),
          primary: const Color(0xFFEE8E42),   // Orange
          secondary: const Color(0xFF23529C), // Bleu
          tertiary: const Color(0xFF10B981),  // Vert Succès
          surface: const Color(0xFFF8F9FA),
          error: const Color(0xFFDC2626),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),

      // Injection du Chatbot Khady sur tous les écrans via le builder
      builder: (context, child) {
        return KhadyChatWrapper(child: child!);
      },

      // Écran de démarrage dynamique
      home: _getInitialScreen(),

      // Table des routes pour la navigation nommée
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/vendeur': (context) => const OrderListScreen(),
        '/livreur': (context) => const LivreurBatchesListScreen(),
      },
    );
  }

  /// Logique de détermination de l'écran d'accueil selon le rôle
  Widget _getInitialScreen() {
    // Si pas de session active, retour à l'accueil/login
    if (initialUser == null || initialUser!.roles.isEmpty) {
      return const WelcomeScreen();
    }

    // Récupération du rôle principal (premier de la liste)
    final role = initialUser!.roles.first;

    switch (role) {
      case Role.ADMIN:
        return const AdminDashboardScreen();
      case Role.VENDEUR:
        return const OrderListScreen();
      case Role.LIVREUR:
        return const LivreurBatchesListScreen();
      default:
        return const WelcomeScreen();
    }
  }
}