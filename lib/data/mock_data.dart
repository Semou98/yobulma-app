import '../models/user_model.dart';
import '../core/enums.dart';
import '../models/order_model.dart';
import '../models/batch_model.dart';
import '../models/location_model.dart';

class MockData {
  static List<User> users = [
    User(
      id: 'admin-001',
      phoneNumber: '771112233',
      email: 'admin@yobulma.sn',
      roles: [Role.ADMIN],
      name: 'Responsable Yobulma',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'vendeur-001',
      phoneNumber: '772223344',
      email: 'boutique.dak@email.com',
      roles: [Role.VENDEUR],
      name: 'Boutique Dakar Mode',
      adresse: 'Plateau, Rue 12',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'livreur-001',
      phoneNumber: '773334455',
      roles: [Role.LIVREUR],
      name: 'Moussa Diop',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  // Liste des commandes (Nécessaire pour lier aux Batches)
  static List<Order> orders = [
    Order(
      id: 'ORD-001',
      vendeurId: 'vendeur-001',
      clientName: 'Fatou Ndiaye',
      clientPhone: '771234567',
      deliveryLocation: Location(quartier: 'Plateau', adresse: 'Rue 6, Médina'),
      colisDescription: 'Sac à main',
      otp: '1234',
      trackingLink: 'https://yobulma.app/track/ORD-001',
      status: OrderStatus.EN_ATTENTE_DE_LIVREUR,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Order(
      id: 'ORD-002',
      vendeurId: 'vendeur-001',
      clientName: 'Abdoulaye Wade',
      clientPhone: '777654321',
      deliveryLocation: Location(
        quartier: 'Plateau',
        adresse: 'Avenue Pompidou',
      ),
      colisDescription: 'Chaussures sport',
      otp: '5678',
      trackingLink: 'https://yobulma.app/track/ORD-002',
      status: OrderStatus.EN_ATTENTE_DE_LIVREUR,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  // Liste des Batches (C'est ce qui manquait à votre erreur)
  static List<Batch> batches = [
    Batch(
      id: 'BATCH-001',
      quartier: 'Plateau',
      vendorName: 'Boutique Dakar Mode',
      deliveryFee: 2500.0,
      orderIds: ['ORD-001', 'ORD-002'],
      status: BatchStatus.DISPONIBLE,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Batch(
      id: 'BATCH-002',
      quartier: 'Mermoz',
      vendorName: 'Electro Shop',
      deliveryFee: 1800.0,
      orderIds: ['ORD-003'],
      status: BatchStatus.DISPONIBLE,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static void addUser(User newUser) => users.add(newUser);
}
