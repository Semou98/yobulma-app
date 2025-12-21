import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/vendeur/order_detail_screen.dart';
import '../../data/mock_data.dart';
import '../../models/order_model.dart';
import '../../core/enums.dart';
import 'create_order_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  Widget build(BuildContext context) {
    // Filtrage des commandes du vendeur actuel (vendeur-001)
    final myOrders = MockData.orders
        .where((o) => o.vendeurId == 'vendeur-001')
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Mes Expéditions",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Color(0xFFFF9800),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF9800),
            tabs: [
              Tab(text: "En attente"),
              Tab(text: "En cours"),
              Tab(text: "Livrées"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(myOrders, OrderStatus.EN_ATTENTE_DE_LIVREUR),
            _buildOrderList(myOrders, OrderStatus.EN_COURS_DE_LIVRAISON),
            _buildOrderList(myOrders, OrderStatus.LIVREE),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
            ).then((_) => setState(() {})); // Rafraîchir la liste au retour
          },
          label: const Text(
            "Nouveau colis",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> allOrders, OrderStatus status) {
    final filteredOrders = allOrders.where((o) => o.status == status).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              "Aucune commande ${status.name.toLowerCase().replaceAll('_', ' ')}",
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return GestureDetector(
          // Ajoute ceci autour ou utilise le onTap de ListTile
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(order: order),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.clientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    order.id.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    "📍 ${order.deliveryLocation.quartier} - ${order.deliveryLocation.adresse}",
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.vpn_key_outlined,
                        size: 14,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "OTP: ${order.otp}",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: _buildStatusBadge(order.status),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.LIVREE:
        color = Colors.green;
        break;
      case OrderStatus.EN_COURS_DE_LIVRAISON:
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.split('.').last.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
