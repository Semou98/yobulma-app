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
        // Recherche de l'utilisateur dans les données mockées [cite: 172]
        final user = MockData.users.firstWhere(
          (u) => u.phoneNumber == _phoneController.text.trim(),
        );

        setState(() => _isLoading = false);

        // Redirection basée sur le premier rôle de l'utilisateur [cite: 45]
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
          const SnackBar(
            content: Text(
              "Numéro non reconnu (Utilisez les numéros du MockData)",
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Couleur principale
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bon retour !",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Connectez-vous pour gérer vos livraisons.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Champ de saisie (Simplicité demandée) [cite: 8]
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Numéro de téléphone",
                labelStyle: const TextStyle(color: Colors.black),
                hintText: "Ex: 771112233",
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFFF9800),
                    width: 2,
                  ), // Orange
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Bouton de connexion
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Couleur secondaire
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Se connecter",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),

            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Besoin d'aide ?",
                  style: TextStyle(color: Color(0xFFFF9800)), // Orange
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
