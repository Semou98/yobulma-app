import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/livreur/delivery_map_screen.dart';
import '../../models/batch_model.dart';
import '../../models/order_model.dart';
import '../../data/mock_data.dart';
import '../../core/enums.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final Batch batch;
  const ActiveDeliveryScreen({super.key, required this.batch});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  late List<Order> _localOrders;

  @override
  void initState() {
    super.initState();
    // On filtre les commandes qui appartiennent à ce lot
    _localOrders = MockData.orders
        .where((order) => widget.batch.orderIds.contains(order.id))
        .toList();
  }

  void _verifyOtp(Order order) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Livraison pour ${order.clientName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Saisissez le code OTP reçu par le client :"),
            const SizedBox(height: 15),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Code à 4 chiffres",
                fillColor: Color(0xFFF5F5F5),
                filled: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              // Vérification du code (dans MockData, ORD-001 a '1234')
              if (_controller.text == order.otp) {
                setState(() {
                  order.status = OrderStatus.LIVREE;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Succès ! Colis livré."),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Code OTP invalide !"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("VALIDER", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tournée Active",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // --- AJOUTER CE BLOC ---
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Color(0xFFFF9800)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeliveryMapScreen(batch: widget.batch),
                ),
              );
            },
          ),
        ],
        // -----------------------
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            color: const Color(0xFFFF9800).withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFFF9800)),
                const SizedBox(width: 10),
                Text("Lot : ${widget.batch.id} - ${widget.batch.quartier}"),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _localOrders.length,
              itemBuilder: (context, index) {
                final order = _localOrders[index];
                final bool isDone = order.status == OrderStatus.LIVREE;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDone ? Colors.green : Colors.black,
                      child: Icon(
                        isDone ? Icons.check : Icons.delivery_dining,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      order.clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(child: Text(order.deliveryLocation.adresse)),
                        // Petite icône de navigation rapide
                        const Icon(
                          Icons.directions,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    trailing: isDone
                        ? const Icon(Icons.verified, color: Colors.green)
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                            ),
                            onPressed: () => _verifyOtp(order),
                            child: const Text(
                              "OTP",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
