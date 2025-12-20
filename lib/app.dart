import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yoboulma_app/screens/auth/role_selection_screen.dart';
import 'package:yoboulma_app/screens/map/map_selection_screen.dart';
import 'repositories/user_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/batch_repository.dart';
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
import 'app_state.dart';

class YoboulmaApp extends StatefulWidget {
  const YoboulmaApp({super.key});

  @override
  State<YoboulmaApp> createState() => _YoboulmaAppState();
}

class _YoboulmaAppState extends State<YoboulmaApp> {
  late final UserRepository _userRepository;
  late final OrderRepository _orderRepository;
  late final BatchRepository _batchRepository;
  late final GoRouter _router;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
    _orderRepository = OrderRepository();
    _batchRepository = BatchRepository();

    // Initialisation asynchrone
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRouter();
    });
  }

  Future<void> _initializeRouter() async {
    _router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) async {
        // Attendre que l'initialisation soit terminée
        await Future.delayed(const Duration(milliseconds: 100));

        final appState = context.read<AppState>();
        final user = FirebaseAuth.instance.currentUser;
        final isLoggedIn = user != null;
        final isLoginRoute =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // Si pas connecté et essaie d'accéder à une route protégée
        if (!isLoggedIn && !isLoginRoute) {
          return '/login';
        }

        // Si connecté et sur login/register, rediriger selon le rôle
        if (isLoggedIn && isLoginRoute) {
          return '/';
        }

        return null;
      },
      routes: [
        // Routes publiques
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
  path: '/role-selection',
  name: 'role_selection',
  builder: (context, state) {
    final user = state.extra as User;
    return RoleSelectionScreen(firebaseUser: user);
  },
),
        
        // Route racine (redirection selon le rôle)
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => _HomeRedirect(
            userRepository: _userRepository,
            orderRepository: _orderRepository,
            batchRepository: _batchRepository,
          ),
        ),
        
        // Admin routes
        GoRoute(
          path: '/admin/dashboard',
          name: 'admin_dashboard',
          builder: (context, state) => MultiProvider(
            providers: [
              Provider<OrderRepository>.value(value: _orderRepository),
              Provider<BatchRepository>.value(value: _batchRepository),
            ],
            child: const AdminDashboardScreen(),
          ),
        ),
        
        // Vendeur routes
        GoRoute(
          path: '/vendeur/orders',
          name: 'vendeur_orders',
          builder: (context, state) => Provider<OrderRepository>.value(
            value: _orderRepository,
            child: const VendeurOrdersScreen(),
          ),
        ),
        
        GoRoute(
          path: '/vendeur/create-order',
          name: 'vendeur_create_order',
          builder: (context, state) => Provider<OrderRepository>.value(
            value: _orderRepository,
            child: const CreateOrderScreen(),
          ),
        ),
        
        GoRoute(
          path: '/vendeur/select-location',
          name: 'vendeur_select_location',
          builder: (context, state) {
            final quartier = state.extra as String?;
            return MapSelectionScreen(quartier: quartier);
          },
        ),
        
        // Livreur routes
        GoRoute(
          path: '/livreur/batches',
          name: 'livreur_batches',
          builder: (context, state) => MultiProvider(
            providers: [
              Provider<OrderRepository>.value(value: _orderRepository),
              Provider<BatchRepository>.value(value: _batchRepository),
            ],
            child: const LivreurBatchesScreen(),
          ),
        ),
        
        GoRoute(
          path: '/livreur/tour/:batchId',
          name: 'livreur_tour',
          builder: (context, state) {
            final batchId = state.pathParameters['batchId']!;
            return MultiProvider(
              providers: [
                Provider<OrderRepository>.value(value: _orderRepository),
                Provider<BatchRepository>.value(value: _batchRepository),
              ],
              child: LivreurTourScreen(batchId: batchId),
            );
          },
        ),
        
        // Client tracking route (public)
        GoRoute(
          path: '/track/:trackingCode',
          name: 'track_order',
          builder: (context, state) {
            final trackingCode = state.pathParameters['trackingCode']!;
            return Provider<OrderRepository>.value(
              value: _orderRepository,
              child: TrackingScreen(trackingCode: trackingCode),
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Page non trouvée',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Route: ${state.uri.path}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 20),
                Text(
                  'Initialisation de l\'application...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: _userRepository),
        Provider<OrderRepository>.value(value: _orderRepository),
        Provider<BatchRepository>.value(value: _batchRepository),
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

// Helper widget to redirect based on user role
class _HomeRedirect extends StatefulWidget {
  final UserRepository userRepository;
  final OrderRepository orderRepository;
  final BatchRepository batchRepository;

  const _HomeRedirect({
    required this.userRepository,
    required this.orderRepository,
    required this.batchRepository,
  });

  @override
  State<_HomeRedirect> createState() => _HomeRedirectState();
}

class _HomeRedirectState extends State<_HomeRedirect> {
  UserRole? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Attendre un peu pour éviter les conflits avec le build
    await Future.delayed(const Duration(milliseconds: 100));
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    try {
      final user = await widget.userRepository.getCurrentUser();
      if (mounted) {
        setState(() {
          _userRole = user?.role;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur getUserRole: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                'Chargement de votre profil...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    switch (_userRole) {
      case UserRole.admin:
        return MultiProvider(
          providers: [
            Provider<OrderRepository>.value(value: widget.orderRepository),
            Provider<BatchRepository>.value(value: widget.batchRepository),
          ],
          child: const AdminDashboardScreen(),
        );
      case UserRole.vendeur:
        return Provider<OrderRepository>.value(
          value: widget.orderRepository,
          child: const VendeurOrdersScreen(),
        );
      case UserRole.livreur:
        return MultiProvider(
          providers: [
            Provider<OrderRepository>.value(value: widget.orderRepository),
            Provider<BatchRepository>.value(value: widget.batchRepository),
          ],
          child: const LivreurBatchesScreen(),
        );
      case UserRole.client:
        // Pour le client, rediriger vers une page de commande ou de suivi
        return Provider<OrderRepository>.value(
          value: widget.orderRepository,
          child: const TrackingScreen(trackingCode: ''),
        );
      default:
        return const LoginScreen();
    }
  }
}