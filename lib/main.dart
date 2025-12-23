import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Imports des écrans
import 'package:yoboulma_app/chatbot_khady.dart';
import 'package:yoboulma_app/screens/auth/splash_screen.dart'; // Import du nouveau Splash
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
  // Initialisation nécessaire pour SharedPreferences avant le runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Fixer l'orientation en portrait uniquement
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Récupération de l'utilisateur stocké pour savoir où rediriger après le Splash
  User? loggedUser;
  try {
    loggedUser = await AuthService.getUser();
  } catch (e) {
    debugPrint("Erreur session: $e");
  }

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
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEE8E42),
          primary: const Color(0xFFEE8E42),
          secondary: const Color(0xFF23529C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      builder: (context, child) {
        return KhadyChatWrapper(child: child!);
      },
      
      // L'erreur ici disparaîtra une fois le constructeur de SplashScreen mis à jour
      home: SplashScreen(nextRoute: _getLandingRoute()),

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

  String _getLandingRoute() {
    if (initialUser == null || initialUser!.roles.isEmpty) {
      return '/welcome';
    }

    final role = initialUser!.roles.first;
    switch (role) {
      case Role.ADMIN: return '/admin';
      case Role.VENDEUR: return '/vendeur';
      case Role.LIVREUR: return '/livreur';
      default: return '/welcome';
    }
  }
}
