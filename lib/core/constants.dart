import 'package:yoboulma_app/core/enums.dart';

class AppConstants {
  // API
  static const String baseUrl = 'http://localhost:8000/api';

  // Quartiers de Dakar
  static const List<String> quartiers = [
    'Plateau',
    'Médina',
    'Parcelles Assainies',
    'Grand Yoff',
    'Ouakam',
    'Mermoz',
    'Sacré-Coeur',
    'Liberté 6',
    'HLM',
    'Point E',
  ];

  // Batch
  static const int maxOrdersPerBatch = 5;

  // Tracking
  static String generateTrackingLink(String orderId) {
    return 'https://yobulma.app/track/$orderId';
  }

  // Status Labels
  static const Map<OrderStatus, String> orderStatusLabels = {
    OrderStatus.EN_ATTENTE_DE_LIVREUR: 'En attente de livreur',
    OrderStatus.PRISE_EN_CHARGE: 'Prise en charge',
    OrderStatus.EN_COURS_DE_LIVRAISON: 'En cours de livraison',
    OrderStatus.ARRIVE_A_DESTINATION: 'Arrivé à destination',
    OrderStatus.LIVREE: 'Livré',
  };
}
