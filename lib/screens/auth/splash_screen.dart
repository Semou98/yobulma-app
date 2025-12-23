import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final String nextRoute;

  const SplashScreen({super.key, required this.nextRoute});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Attend 3 secondes puis navigue vers la route calculée dans main.dart
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, widget.nextRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Votre Logo
            Image.asset(
              'lib/images/YOBULMA LOGO_Plan de travail 1.png',
              height: 150,
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.bolt_rounded, size: 100, color: Color(0xFF23529C)),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE8E42)),
            ),
          ],
        ),
      ),
    );
  }
}