import 'dart:convert';
import '../../models/order_model.dart';
import '../../models/batch_model.dart';

class DatabaseService {
  // Simulation d'un stockage JSON
  static String _jsonOrders = '[]';
  static String _jsonBatches = '[]';

  // Sauvegarder une commande (Conversion Objet -> JSON)
  static void saveOrder(Order order) {
    List<dynamic> list = jsonDecode(_jsonOrders);
    list.add(order.toJson()); // Assurez-vous d'avoir toJson() dans votre modèle
    _jsonOrders = jsonEncode(list);
  }

  // Récupérer les commandes (Conversion JSON -> Objet)
  static List<Order> getAllOrders() {
    Iterable list = jsonDecode(_jsonOrders);
    return list.map((model) => Order.fromJson(model)).toList();
  }
}