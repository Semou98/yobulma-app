import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'repositories/user_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/vendeur/create_order_screen.dart';
import 'screens/vendeur/order_screen.dart';
import 'screens/livreur/batches_screen.dart';
import 'screens/livreur/tour_screen.dart';
import 'screens/client/tracking_screen.dart';
import 'utils/enums.dart';
import 'utils/constants.dart';

class YoboulmaApp extends StatelessWidget {
  const YoboulmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserRepository>(create: (_) => UserRepository()),
      ],
      child: MaterialApp.router(
        title: 'Yoboulma',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final isLoginRoute = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/register';

    // If not logged in and trying to access protected route
    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }

    // If logged in and on login/register, redirect to home based on role
    if (isLoggedIn && isLoginRoute) {
      // We'll determine the route based on user role
      // For now, redirect to a default route
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const _HomeRedirect(),
    ),
    // Admin routes
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    // Vendeur routes
    GoRoute(
      path: '/vendeur/orders',
      builder: (context, state) => const VendeurOrdersScreen(),
    ),
    GoRoute(
      path: '/vendeur/create-order',
      builder: (context, state) => const CreateOrderScreen(),
    ),
    // Livreur routes
    GoRoute(
      path: '/livreur/batches',
      builder: (context, state) => const LivreurBatchesScreen(),
    ),
    GoRoute(
      path: '/livreur/tour/:batchId',
      builder: (context, state) {
        final batchId = state.pathParameters['batchId']!;
        return LivreurTourScreen(batchId: batchId);
      },
    ),
    // Client tracking route (public)
    GoRoute(
      path: '/track/:trackingCode',
      builder: (context, state) {
        final trackingCode = state.pathParameters['trackingCode']!;
        return TrackingScreen(trackingCode: trackingCode);
      },
    ),
  ],
);

// Helper widget to redirect based on user role
class _HomeRedirect extends StatelessWidget {
  const _HomeRedirect();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserRole(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          // En cas d'erreur (ex: Firebase non configuré), afficher l'écran de login
          debugPrint('Erreur lors de la récupération du rôle: ${snapshot.error}');
          return const LoginScreen();
        }

        final role = snapshot.data;
        switch (role) {
          case UserRole.admin:
            return const AdminDashboardScreen();
          case UserRole.vendeur:
            return const VendeurOrdersScreen();
          case UserRole.livreur:
            return const LivreurBatchesScreen();
          case UserRole.client:
            return const VendeurOrdersScreen(); // Clients can see orders too
          default:
            return const LoginScreen();
        }
      },
    );
  }

  Future<UserRole?> _getUserRole(BuildContext context) async {
    try {
      final userRepo = Provider.of<UserRepository>(context, listen: false);
      final user = await userRepo.getCurrentUser();
      return user?.role;
    } catch (e) {
      debugPrint('Erreur getUserRole: $e');
      return null;
    }
  }
}

