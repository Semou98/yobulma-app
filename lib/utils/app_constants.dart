
// lib/utils/app_constants.dart
class AppConstants {
  // Configuration OTP
  static const int otpLength = 6;
  static const int otpExpirationMinutes = 10;
  
  // Configuration des commandes
  static const int maxOrdersPerBatch = 5;
  static const double maxBatchRadiusKm = 10.0;
  
  // Prix de livraison
  static const double baseDeliveryPrice = 500.0; // FCFA
  static const double pricePerKm = 100.0; // FCFA par km
  
  // Quartiers de Dakar (liste d'exemple)
  static const List<String> dakarQuartiers = [
    'Plateau',
    'Médina',
    'Gueule Tapée',
    'Fass',
    'Colobane',
    'Ouakam',
    'Mermoz',
    'Sicap',
    'Liberté',
    'Grand Dakar',
    'Parcelles Assainies',
    'Yoff',
    'Ngor',
    'Almadies',
    'Dakar-Plateau',
    'Dakar-Médina',
    'Dakar-Fann',
    'Dakar-Ouakam',
  ];
  
  // Statuts des commandes
  static const List<String> orderStatuses = [
    'En attente',
    'Acceptée',
    'En préparation',
    'Prête',
    'En livraison',
    'Livrée',
    'Annulée',
  ];
  
  // Types de véhicules
  static const List<String> vehicleTypes = [
    'Moto',
    'Voiture',
    'Vélo',
    'Camionnette',
  ];
}