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

  static List<Order> orders = [
    Order(
      id: 'ORD-001',
      vendeurId: 'vendeur-001',
      clientName: 'Fatou Ndiaye',
      clientPhone: '771234567',
      deliveryLocation: Location(
        quartier: 'Sacré-Cœur 3',
        adresse: 'Près de la Boulangerie Jaune',
        latitude: 14.75265,
        longitude: -17.46904,
      ),
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
        quartier: 'Mermoz',
        adresse: 'Immeuble CBAO',
        latitude: 14.75100,
        longitude: -17.47100,
      ),
      colisDescription: 'Chaussures sport',
      otp: '5678',
      trackingLink: 'https://yobulma.app/track/ORD-002',
      status: OrderStatus.EN_ATTENTE_DE_LIVREUR,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Order(
      id: 'ORD-004',
      vendeurId: 'vendeur-001',
      clientName: 'Mamadou Fall',
      clientPhone: '779998877',
      deliveryLocation: Location(
        quartier: 'Vdn',
        adresse: 'Après le siège de Orange',
        latitude: 14.75400,
        longitude: -17.46700,
      ),
      colisDescription: 'Accessoires électroniques',
      otp: '1122',
      trackingLink: 'https://yobulma.app/track/ORD-004',
      status: OrderStatus.EN_ATTENTE_DE_LIVREUR,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Order(
      id: 'ORD-003',
      vendeurId: 'vendeur-001',
      clientName: 'Aissatou Sow',
      clientPhone: '778889900',
      deliveryLocation: Location(
        quartier: 'Grand Dakar',
        adresse: 'Rue 10 prolongée',
        latitude: 14.72522,
        longitude: -17.44175,
      ),
      colisDescription: 'Vêtements divers',
      otp: '9101',
      trackingLink: 'https://yobulma.app/track/ORD-003',
      status: OrderStatus.EN_ATTENTE_DE_LIVREUR,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Order(
      id: 'ORD-005',
      vendeurId: 'vendeur-001',
      clientName: 'Ibrahima Sarr',
      clientPhone: '775556677',
      deliveryLocation: Location(
        quartier: 'Sicap Baobab',
        adresse: 'Près de la station Shell',
        latitude: 14.72700,
        longitude: -17.44300,
      ),
      colisDescription: 'Parfum Luxe',
      otp: '4433',
      trackingLink: 'https://yobulma.app/track/ORD-005',
      status: OrderStatus.EN_ATTENTE_DE_LIVREUR,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<Batch> batches = [
    Batch(
      id: 'Groupage-001',
      quartier: 'Sacré-Cœur / Mermoz',
      vendorName: 'Boutique Dakar Mode',
      deliveryFee: 2500.0,
      orderIds: ['ORD-001', 'ORD-002', 'ORD-004'],
      status: BatchStatus.DISPONIBLE,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // deliveries: [] supprimé ici
    ),
    Batch(
      id: 'Groupage-002',
      quartier: 'Grand Dakar / Baobab',
      vendorName: 'Electro Shop',
      deliveryFee: 1800.0,
      orderIds: ['ORD-003', 'ORD-005'],
      status: BatchStatus.DISPONIBLE,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // deliveries: [] supprimé ici
    ),
  ];

  static void addUser(User newUser) => users.add(newUser);
}