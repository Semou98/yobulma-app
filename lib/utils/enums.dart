enum UserRole {
  vendeur,
  livreur,
  client,
  admin,
}

enum OrderStatus {
  enAttenteDeLivreur, // EN_ATTENTE_DE_LIVREUR
  priseEnCharge, // PRISE_EN_CHARGE
  enRoute, // EN_ROUTE
  arriveADestination, // ARRIVÉ_A_DESTINATION
  livre, // LIVRÉ
  cancelled, enCoursDeLivraison, ready, preparing, accepted, pending, onDelivery, delivered, annule, // Annulé
}

enum BatchStatus {
  pending, // En attente de livreur
  priseEnCharge, // PRISE_EN_CHARGE (accepté par livreur)
  enCours, // En cours de livraison
  completed, // Terminé
  cancelled, // Annulé
}

enum PaymentMethod {
  cash, // Paiement à la livraison
  wave,
  orangeMoney,
  freeMoney,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
}

