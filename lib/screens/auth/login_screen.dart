import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/admin/dashboard_screen.dart';
import 'package:yoboulma_app/screens/livreur/batches_list_screen.dart';
import 'package:yoboulma_app/screens/vendeur/orders_list_screen.dart';
import 'package:yoboulma_app/services/auth_service.dart';
import '../../models/user_model.dart';
import '../../data/mock_data.dart';
import '../../core/enums.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    final phoneInput = _phoneController.text.trim();

    if (phoneInput.isEmpty) {
      _showErrorSnackbar("Veuillez entrer votre numéro");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Chercher en local (JSON)
      User? registeredUser = await AuthService.getUser();
      User? userToLogIn;

      if (registeredUser != null && registeredUser.phoneNumber == phoneInput) {
        userToLogIn = registeredUser;
      } else {
        // 2. Chercher dans les Mocks
        try {
          userToLogIn = MockData.users.firstWhere((u) => u.phoneNumber == phoneInput);
        } catch (e) {
          userToLogIn = null;
        }
      }

      await Future.delayed(const Duration(seconds: 1));
      
      // SÉCURITÉ : Vérifier si l'écran est toujours affiché
      if (!mounted) return;

      if (userToLogIn != null) {
        // IMPORTANT : Sauvegarder AVANT de naviguer pour que le prochain écran 
        // puisse lire les données si besoin
        await AuthService.saveUser(userToLogIn);
        
        setState(() => _isLoading = false);

        // Navigation
        _navigateToDashboard(userToLogIn);
      } else {
        // Si userToLogIn est null, on tombe ici
        setState(() => _isLoading = false);
        _showErrorSnackbar("Numéro non reconnu");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar("Erreur de connexion");
      }
    }
  }

  void _navigateToDashboard(User user) {
    Widget nextScreen;
    if (user.roles.contains(Role.ADMIN)) {
      nextScreen = const AdminDashboardScreen();
    } else if (user.roles.contains(Role.VENDEUR)) {
      nextScreen = const OrderListScreen();
    } else {
      nextScreen = const LivreurBatchesListScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  // ... (Garder tes méthodes de build UI identiques à ton code original)
  
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFEE8E42),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 40),
                _buildLoginForm(),
                const SizedBox(height: 30),
                _buildLoginButton(),
                const SizedBox(height: 25),
                _buildAdditionalOptions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: Colors.grey.shade700),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Connexion",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          "Entrez votre numéro pour accéder à votre compte",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.4),
        ),
        const SizedBox(height: 40),
        _buildPhoneInputField(),
      ],
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: const Text("🇸🇳 +221", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "77 123 45 67",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF23529C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text("Continuer", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/register'),
        child: const Text("Pas encore de compte ? S'inscrire"),
      ),
    );
  }
}