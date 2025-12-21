import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/order_model.dart';
import '../../models/location_model.dart';
import '../../data/mock_data.dart';
import '../../core/enums.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour récupérer les textes
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedQuartier = 'Plateau';
  final List<String> _quartiers = [
    'Plateau',
    'Medina',
    'Mermoz',
    'Almadies',
    'Guediawaye',
    'Pikine',
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 1. Génération automatique des données de sécurité
      final String generatedOtp = (Random().nextInt(9000) + 1000)
          .toString(); // Ex: 4521
      final String orderId =
          "ORD-${Random().nextInt(9999).toString().padLeft(4, '0')}";
      final String trackLink = "https://yobulma.app/track/$orderId";

      // 2. Création de l'objet Order selon ton modèle
      final newOrder = Order(
        id: orderId,
        vendeurId: 'vendeur-001', // Id fixe pour la démo
        clientName: _nameController.text,
        clientPhone: _phoneController.text,
        deliveryLocation: Location(
          quartier: _selectedQuartier,
          adresse: _addressController.text,
          latitude: 0.0,
          longitude: 0.0,
        ),
        colisDescription: _descController.text,
        otp: generatedOtp,
        trackingLink: trackLink,
        status: OrderStatus.EN_ATTENTE_DE_LIVREUR,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 3. Ajout au MockData
      setState(() {
        MockData.orders.add(newOrder);
      });

      // 4. Feedback visuel
      _showSuccessDialog(newOrder);
    }
  }

  void _showSuccessDialog(Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Commande Créée"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Veuillez transmettre ce code au client :"),
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.otp,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text("ID: ${order.id}", style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme le dialog
              Navigator.pop(context); // Retourne à la liste
            },
            child: const Text("TERMINER"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nouvelle Expédition"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informations Client",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom complet",
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Téléphone",
                  prefixIcon: Icon(Icons.phone_android),
                ),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 25),
              const Text(
                "Livraison",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedQuartier,
                decoration: const InputDecoration(
                  labelText: "Quartier",
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                items: _quartiers
                    .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedQuartier = v!),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Adresse précise",
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description du colis",
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? "Décrivez le colis" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "ENREGISTRER LA COMMANDE",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
