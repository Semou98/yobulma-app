import 'package:flutter/material.dart';
import 'package:yoboulma_app/chatbot_khady.dart';
import 'package:yoboulma_app/screens/auth/login_screen.dart';
import 'package:yoboulma_app/screens/auth/register_screen.dart';
import 'package:yoboulma_app/screens/auth/welcome_screen.dart';
import 'package:yoboulma_app/screens/admin/dashboard_screen.dart';
import 'package:yoboulma_app/screens/vendeur/orders_list_screen.dart';
import 'package:yoboulma_app/screens/livreur/batches_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Version simplifiée pour déboguer
  runApp(const YobulmaApp());
}

class YobulmaApp extends StatelessWidget {
  final String? initialRole;

  const YobulmaApp({super.key, this.initialRole});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yobulma',
      debugShowCheckedModeBanner: false,
      
      // Thème personnalisé
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

      // Utilisation du builder pour injecter Khady partout
      builder: (context, child) {
        return KhadyChatWrapper(child: child!);
      },

      // Routes nommées pour navigation
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/vendeur': (context) => const OrderListScreen(),
        '/livreur': (context) => const LivreurBatchesListScreen(),
      },

      // Écran d'accueil avec Builder pour avoir un contexte
      home: Builder(
        builder: (context) {
          return _getInitialScreen(context);
        },
      ),
    );
  }

  Widget _getInitialScreen(BuildContext context) {
    print('Rôle initial: $initialRole');
    
    // Si pas de rôle, retourner WelcomeScreen
    if (initialRole == null || initialRole!.isEmpty) {
      print('Aucun rôle sauvegardé');
      return const WelcomeScreen();
    }

    print('Tentative de redirection pour le rôle: $initialRole');
    
    // Redirection selon le rôle
    switch (initialRole) {
      case 'ADMIN':
        print('Redirection vers AdminDashboardScreen');
        return const AdminDashboardScreen();
      case 'VENDEUR':
        print('Redirection vers OrderListScreen');
        return const OrderListScreen();
      case 'LIVREUR':
        print('Redirection vers LivreurBatchesListScreen');
        return const LivreurBatchesListScreen();
      default:
        print('Rôle non reconnu, retour à WelcomeScreen');
        return const WelcomeScreen();
    }
  }
}