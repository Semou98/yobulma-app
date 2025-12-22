import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/admin/dashboard_screen.dart';
import 'package:yoboulma_app/screens/livreur/batches_list_screen.dart';
import 'package:yoboulma_app/screens/vendeur/orders_list_screen.dart';
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

  void _handleLogin() {
    // Validation basique
    if (_phoneController.text.trim().isEmpty) {
      _showErrorSnackbar("Veuillez entrer votre numéro");
      return;
    }

    setState(() => _isLoading = true);

    // Simulation d'un délai réseau
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return; // Sécurité pour éviter les fuites de mémoire

      try {
        // Recherche de l'utilisateur dans les données mockées
        final user = MockData.users.firstWhere(
          (u) => u.phoneNumber == _phoneController.text.trim(),
        );

        setState(() => _isLoading = false);

        // Navigation basée sur le rôle
        Widget nextScreen;
        if (user.roles.contains(Role.ADMIN)) {
          nextScreen = const AdminDashboardScreen();
        } else if (user.roles.contains(Role.VENDEUR)) {
          nextScreen = const OrderListScreen();
        } else if (user.roles.contains(Role.LIVREUR)) {
          nextScreen = const LivreurBatchesListScreen();
        } else {
          throw Exception("Rôle inconnu");
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
        );

      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackbar("Numéro non reconnu ou accès refusé");
      }
    });
  }

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
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Entrez votre numéro pour accéder à votre compte",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.4),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4),
          child: Text(
            "Numéro de téléphone",
            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    const Text("🇸🇳", style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      "+221",
                      style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    hintText: "77 123 45 67",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 4),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                "Nous vous enverrons un code de vérification",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
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
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : const Text("Continuer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      children: [
        Center(
          child: TextButton(
            onPressed: () {},
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "Besoin d'aide ? ", style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
                  const TextSpan(
                    text: "Contactez-nous",
                    style: TextStyle(color: Color(0xFFEE8E42), fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => setState(() => _phoneController.text = "771112233"),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF23529C),
              side: BorderSide(color: const Color(0xFF23529C).withOpacity(0.3), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: const Color(0xFF23529C).withOpacity(0.05),
            ),
            child: const Text("Utiliser un compte démo (Admin)", style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}