import 'package:flutter/material.dart';
import 'package:yoboulma_app/chatbot_khady.dart';
import 'package:yoboulma_app/screens/auth/login_screen.dart';
import 'package:yoboulma_app/screens/auth/register_screen.dart';
import 'package:yoboulma_app/screens/auth/welcome_screen.dart';
import 'package:yoboulma_app/screens/admin/dashboard_screen.dart';
import 'package:yoboulma_app/screens/vendeur/orders_list_screen.dart';
import 'package:yoboulma_app/screens/livreur/batches_list_screen.dart';
import 'package:yoboulma_app/services/auth_service.dart';

// Import de tes services et modèles
import 'models/user_model.dart';
import 'core/enums.dart';

void main() async {
  // Indispensable pour utiliser SharedPreferences avant runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. On récupère l'utilisateur stocké en JSON
  User? loggedUser = await AuthService.getUser();
  
  // 2. On lance l'app avec l'utilisateur (s'il existe)
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
      
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEE8E42),
          primary: const Color(0xFFEE8E42),
          secondary: const Color(0xFF23529C),
          tertiary: const Color(0xFF10B981),
          surface: const Color(0xFFF8F9FA),
          error: const Color(0xFFDC2626),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),

      // Injection du Chatbot Khady sur tous les écrans
      builder: (context, child) {
        return KhadyChatWrapper(child: child!);
      },

      // Routes nommées
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/vendeur': (context) => const OrderListScreen(),
        '/livreur': (context) => const LivreurBatchesListScreen(),
      },

      // Écran de démarrage dynamique
      home: _getInitialScreen(),
    );
  }

  /// Logique de redirection automatique au démarrage
  Widget _getInitialScreen() {
    if (initialUser == null) {
      return const WelcomeScreen();
    }

    // On vérifie le premier rôle de l'utilisateur
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