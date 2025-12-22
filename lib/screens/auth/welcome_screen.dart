import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/auth/login_screen.dart';
import 'package:yoboulma_app/screens/auth/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Couleurs de la charte
  static const Color _blue = Color(0xFF23529C);
  static const Color _orange = Color(0xFFEE8E42);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Éléments de fond pour le modernisme
          Positioned(
            top: -50,
            left: -50,
            child: _buildBackgroundCircle(_orange.withOpacity(0.05), 200),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _buildBackgroundCircle(_blue.withOpacity(0.05), 250),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centre verticalement tout le contenu
                children: [
                  const Spacer(flex: 2),
                  
                  // --- SECTION LOGO CENTRÉE ---
                  _buildHeroSection(),
                  
                  const Spacer(flex: 2),
                  
                  // --- SECTION BOUTONS ---
                  _buildActionButtons(context),
                  
                  const SizedBox(height: 10),
                  
                  // Version de l'app ou slogan discret
                  Text(
                    "v 1.0.0 • Made with ❤️ for Dakar",
                    style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 10),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container du Logo avec ombre portée douce
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _blue.withOpacity(0.1),
                blurRadius: 40,
                spreadRadius: 5,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Hero(
            tag: 'logo_hero',
            child: Image.asset(
              'lib/images/YOBULMA LOGO_Plan de travail 1.png',
              height: 270, // Taille optimisée
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.bolt_rounded, size: 120, color: _blue),
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Titre Principal
        const Text(
          'YOBULMA',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: _blue,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Slogan avec dégradé de sens
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(fontSize: 16, height: 1.5, fontFamily: 'Roboto'),
            children: [
              TextSpan(
                text: 'La livraison de confiance à Dakar\n',
                style: TextStyle(color: _orange, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'Optimisé pour commerçants & livreurs.',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Bouton Se Connecter - Moderne avec léger dégradé
        _buildButton(
          text: 'Se connecter',
          color: _blue,
          textColor: Colors.white,
          onPressed: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const LoginScreen())
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Bouton S'inscrire - Design Outlined pur
        _buildButton(
          text: "Créer un compte",
          color: Colors.transparent,
          textColor: _blue,
          isOutlined: true,
          onPressed: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const RegisterScreen())
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isOutlined ? [] : [
          BoxShadow(
            color: _blue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isOutlined 
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _blue, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              foregroundColor: _blue,
            ),
            child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
    );
  }
}