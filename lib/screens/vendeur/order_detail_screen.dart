import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/order_model.dart';
import '../../core/enums.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détails ${order.id}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 25),
            _buildSectionTitle("Informations de Livraison"),
            _buildInfoCard(Icons.person, "Client", order.clientName),
            _buildInfoCard(Icons.phone, "Téléphone", order.clientPhone),
            _buildInfoCard(
              Icons.location_on,
              "Adresse",
              "${order.deliveryLocation.quartier}, ${order.deliveryLocation.adresse}",
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Sécurité & Suivi"),
            _buildOtpCard(context),
            const SizedBox(height: 10),
            _buildTrackingCard(context),
            const SizedBox(height: 20),
            _buildSectionTitle("Contenu du colis"),
            _buildInfoCard(
              Icons.inventory_2,
              "Description",
              order.colisDescription,
            ),
            const SizedBox(height: 30),
            _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor()),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: _getStatusColor()),
          const SizedBox(width: 10),
          Text(
            "Statut : ${order.status.name.replaceAll('_', ' ')}",
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpCard(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: ListTile(
        leading: const Icon(Icons.lock, color: Colors.blue),
        title: const Text("Code OTP Client", style: TextStyle(fontSize: 14)),
        subtitle: Text(
          order.otp,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: order.otp));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("OTP copié !")));
          },
        ),
      ),
    );
  }

  Widget _buildTrackingCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.track_changes, color: Color(0xFFFF9800)),
        title: const Text("Lien de suivi", style: TextStyle(fontSize: 14)),
        subtitle: Text(
          order.trackingLink,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.share),
        onTap: () {
          Clipboard.setData(ClipboardData(text: order.trackingLink));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lien de suivi copié !")),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _buildTimelineStep("Commande créée", order.createdAt, true),
        _buildTimelineStep(
          "Assignée à un livreur",
          null,
          order.status != OrderStatus.EN_ATTENTE_DE_LIVREUR,
        ),
        _buildTimelineStep(
          "Livrée au client",
          null,
          order.status == OrderStatus.LIVREE,
        ),
      ],
    );
  }

  Widget _buildTimelineStep(String label, DateTime? date, bool isDone) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isDone ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(color: isDone ? Colors.black : Colors.grey),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (order.status == OrderStatus.LIVREE) return Colors.green;
    if (order.status == OrderStatus.EN_COURS_DE_LIVRAISON) return Colors.orange;
    return Colors.grey;
  }
}
