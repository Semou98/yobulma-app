import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/order_model.dart';
import '../../core/enums.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  // Couleurs de la marque
  static const Color _primaryColor = Color(0xFFEE8E42); // Orange
  static const Color _secondaryColor = Color(0xFF23529C); // Bleu
  static const Color _backgroundColor = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);

  Color _getStatusColor() {
    if (order.status == OrderStatus.LIVREE) return _successColor;
    if (order.status == OrderStatus.EN_COURS_DE_LIVRAISON) return _warningColor;
    if (order.status == OrderStatus.EN_ATTENTE_DE_LIVREUR) return _primaryColor;
    return _textSecondary;
  }

  String _getStatusText() {
    return order.status.name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          "Expédition ${order.id}",
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: _backgroundColor,
        foregroundColor: _textPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de statut amélioré
            _buildStatusHeader(),
            
            const SizedBox(height: 25),
            
            // Section Informations de Livraison
            _buildSectionTitle("Informations de Livraison"),
            
            _buildInfoCard(
              Icons.person_outline_rounded,
              "Client",
              order.clientName,
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoCard(
              Icons.phone_iphone_rounded,
              "Téléphone",
              order.clientPhone,
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoCard(
              Icons.location_on_outlined,
              "Adresse",
              "${order.deliveryLocation.quartier}, ${order.deliveryLocation.adresse}",
            ),
            
            const SizedBox(height: 25),
            
            // Section Sécurité & Suivi
            _buildSectionTitle("Sécurité & Suivi"),
            
            _buildOtpCard(context),
            
            const SizedBox(height: 12),
            
            _buildTrackingCard(context),
            
            const SizedBox(height: 25),
            
            // Section Contenu du colis
            _buildSectionTitle("Contenu du colis"),
            
            _buildInfoCard(
              Icons.inventory_2_outlined,
              "Description",
              order.colisDescription,
            ),
            
            const SizedBox(height: 30),
            
            // Timeline améliorée
            _buildTimeline(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _getStatusColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Créée le ${_formatDate(order.createdAt)}",
                  style: TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: _textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: _secondaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _secondaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _secondaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: _secondaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Code de sécurité OTP",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: _secondaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _secondaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                order.otp,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: _secondaryColor,
                  fontFamily: 'Monospace',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Transmettez ce code au client pour valider la livraison",
                  style: TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _copyToClipboard(
                  context,
                  order.otp,
                  "Code OTP copié !",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text("Copier"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.track_changes_rounded,
              size: 20,
              color: _primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lien de suivi",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.trackingLink,
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              IconButton(
                onPressed: () => _copyToClipboard(
                  context,
                  order.trackingLink,
                  "Lien copié !",
                ),
                icon: Icon(
                  Icons.copy_rounded,
                  color: _primaryColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Action de partage
                },
                icon: Icon(
                  Icons.share_rounded,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
  final steps = [
    _TimelineStep(
      title: "Commande créée",
      date: order.createdAt,
      isCompleted: true,
    ),
    _TimelineStep(
      title: "Assignée à un livreur",
      date: order.status != OrderStatus.EN_ATTENTE_DE_LIVREUR
          ? order.updatedAt
          : null,
      isCompleted: order.status != OrderStatus.EN_ATTENTE_DE_LIVREUR,
    ),
    _TimelineStep(
      title: "Livrée au client",
      date: order.status == OrderStatus.LIVREE ? order.updatedAt : null,
      isCompleted: order.status == OrderStatus.LIVREE,
    ),
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          "Suivi de la commande",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: steps.asMap().entries.map((entry) => 
            _buildTimelineStep(entry.value, entry.key, steps)
          ).toList(),
        ),
      ),
    ],
  );
}

  Widget _buildTimelineStep(_TimelineStep step, int index, List<_TimelineStep> steps) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicateur de progression
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step.isCompleted ? _successColor : _borderColor,
                border: Border.all(
                  color: step.isCompleted ? _successColor : _borderColor,
                  width: 2,
                ),
              ),
              child: step.isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            // Ne pas afficher la ligne verticale pour le dernier élément
            if (index < steps.length - 1)
              Container(
                width: 2,
                height: 40,
                color: step.isCompleted ? _successColor : _borderColor,
              ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: step.isCompleted ? _textPrimary : _textSecondary,
                ),
              ),
              if (step.date != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatDate(step.date!),
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

  IconData _getStatusIcon() {
    switch (order.status) {
      case OrderStatus.LIVREE:
        return Icons.check_circle_rounded;
      case OrderStatus.EN_COURS_DE_LIVRAISON:
        return Icons.local_shipping_rounded;
      case OrderStatus.EN_ATTENTE_DE_LIVREUR:
        return Icons.hourglass_top_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}

class _TimelineStep {
  final String title;
  final DateTime? date;
  final bool isCompleted;

  _TimelineStep({
    required this.title,
    required this.date,
    required this.isCompleted,
  });
}