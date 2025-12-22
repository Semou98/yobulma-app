import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/livreur/batches_list_screen.dart';
import 'package:yoboulma_app/screens/vendeur/orders_list_screen.dart';
import '../../data/mock_data.dart';
import '../../core/enums.dart';
import '../admin/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() {
    setState(() => _isLoading = true);

    // Simulation d'un délai réseau pour le réalisme du hackathon
    Future.delayed(const Duration(seconds: 1), () {
      try {
        // Recherche de l'utilisateur dans les données mockées
        final user = MockData.users.firstWhere(
          (u) => u.phoneNumber == _phoneController.text.trim(),
        );

        setState(() => _isLoading = false);

        // Redirection basée sur le premier rôle de l'utilisateur
        if (user.roles.contains(Role.ADMIN)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else if (user.roles.contains(Role.VENDEUR)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OrderListScreen()),
          );
        } else if (user.roles.contains(Role.LIVREUR)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LivreurBatchesListScreen()),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Numéro non reconnu",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEE8E42), // Orange secondaire
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
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
                // Header avec logo et bouton retour
                _buildHeader(context),
                const SizedBox(height: 40),
                
                // Formulaire de connexion simplifié
                _buildLoginForm(),
                
                const SizedBox(height: 30),
                
                // Bouton de connexion
                _buildLoginButton(),
                
                const SizedBox(height: 25),
                
                // Options supplémentaires
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
        // Bouton retour
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.grey.shade700,
          ),
        ),
        
        const SizedBox(width: 8),
        
        
        const Spacer(),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
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
        
        // Sous-titre
        Text(
          "Entrez votre numéro pour accéder à votre compte",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Label du champ
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4),
          child: Text(
            "Numéro de téléphone",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Champ de saisie simplifié
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              // Préfixe pays
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
                    Text(
                      "🇸🇳",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "+221",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Champ de saisie
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
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
        
        // Note d'information
        Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 4),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                "Nous vous enverrons un code de vérification par SMS",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
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
          backgroundColor: const Color(0xFF23529C), // Bleu tertiaire
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Continuer",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      children: [
        // Lien d'aide
        Center(
          child: TextButton(
            onPressed: () {
              // Action pour l'aide
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Besoin d'aide ? ",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                  TextSpan(
                    text: "Contactez-nous",
                    style: TextStyle(
                      color: const Color(0xFFEE8E42), // Orange secondaire
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Option de connexion rapide (pour démo)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              _phoneController.text = "771112233"; // Numéro de démo
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF23529C),
              side: BorderSide(
                color: const Color(0xFF23529C).withOpacity(0.3),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: const Color(0xFF23529C).withOpacity(0.05),
            ),
            child: const Text(
              "Utiliser un compte démo",
              style: TextStyle(
                color: Color(0xFF23529C),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}