import 'package:flutter/material.dart';
import 'package:yoboulma_app/chatbot_khady.dart';
import 'package:yoboulma_app/screens/auth/login_screen.dart';
import 'package:yoboulma_app/screens/auth/register_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/vendeur/orders_list_screen.dart';
import 'screens/livreur/batches_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
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
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9800),
          primary: Colors.black,
        ),
      ),
      // Utilisation du builder pour injecter Khady partout
      builder: (context, child) {
        return KhadyChatWrapper(child: child!);
      },
      // Important pour l'exclusion : donnez des noms à vos routes de base
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/welcome':
            page = const WelcomeScreen();
            break;
          case '/login':
            page = const LoginScreen();
            break;
          case '/register':
            page = const RegisterScreen();
            break;
          default:
            page = _getHome(initialRole);
        }
        return MaterialPageRoute(
          builder: (context) => page,
          settings: settings,
        );
      },
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
