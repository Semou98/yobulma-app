import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/auth/login_screen.dart';
import 'package:yoboulma_app/screens/auth/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- SECTION HAUT (Logo et Slogan) ---
                Padding(
                  padding: const EdgeInsets.only(top: 60), // Un peu plus d'espace en haut
                  child: Column(
                    children: [
                      // LOGO AGRANDI
                      Image.asset(
                        'lib/images/YOBULMA LOGO_Plan de travail 1.png',
                        height: 250, // Taille augmentée
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.bolt_rounded, 
                            size: 120, 
                            color: Color(0xFF23529C),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 30), // Espace après le logo
                      
                      // Texte YOBULMA supprimé comme demandé
                      
                      const Text(
                        'La livraison de confiance à Dakar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF23529C),
                          fontSize: 18, // Légèrement agrandi pour l'équilibre
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Solution de livraison optimisée pour les commerçants et livreurs de Dakar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- SECTION BAS (Boutons) ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 40, top: 20),
                  child: Column(
                    children: [
                      // Bouton Se Connecter
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF23529C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Bouton S'inscrire
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF23529C), width: 2),
                            foregroundColor: const Color(0xFF23529C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'S\'inscrire',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      TextButton(
                        onPressed: () {
                          // Action mode invité
                        },
                        child: const Text(
                          'Continuer sans compte',
                          style: TextStyle(
                            color: Color(0xFFEE8E42),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}