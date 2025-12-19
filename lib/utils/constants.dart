import 'package:flutter/material.dart';

// Colors
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03A9F4);
  static const Color accent = Color(0xFF00BCD4);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

// Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

// Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}

// App Constants
class AppConstants {
  // Dakar coordinates
  static const double dakarLat = 14.7167;
  static const double dakarLng = -17.4677;
  
  // Batch configuration
  static const int maxOrdersPerBatch = 5; // Nombre maximum de commandes par batch
  static const double maxBatchRadiusKm = 5.0; // Rayon maximum pour groupage
  
  // OTP
  static const int otpLength = 6;
  static const int otpExpirationMinutes = 15;
  
  // Delivery
  static const double baseDeliveryPrice = 1000.0; // Prix de base en FCFA
  static const double pricePerKm = 200.0; // Prix par km en FCFA
  
  // Quartiers de Dakar (liste prédéfinie)
  static const List<String> dakarQuartiers = [
    'Almadies',
    'Amitié',
    'Biscuiterie',
    'Cité Keur Gorgui',
    'Colobane',
    'Dakar Plateau',
    'Fann',
    'Grand Dakar',
    'Grand Yoff',
    'Hann',
    'HLM',
    'Liberté',
    'Mermoz',
    'Ngor',
    'Ouakam',
    'Parcelles Assainies',
    'Pikine',
    'Point E',
    'Sacré-Cœur',
    'Sicap',
    'Yoff',
  ];
}

