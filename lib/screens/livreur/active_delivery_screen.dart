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

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen>
    with SingleTickerProviderStateMixin {
  late List<Order> _localOrders;
  late AnimationController _animationController;

  // Charte graphique
  static const Color _primaryColor = Color(0xFFEE8E42); // Orange
  static const Color _secondaryColor = Color(0xFF23529C); // Bleu
  static const Color _backgroundColor = Colors.white; // Blanc (couleur principale)
  static const Color _textPrimary = Color(0xFF111827); // Noir
  static const Color _textSecondary = Color(0xFF6B7280); // Gris
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _cardColor = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
    
    _localOrders = MockData.orders
        .where((order) => widget.batch.orderIds.contains(order.id))
        .toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _verifyOtp(Order order) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar client
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _secondaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _secondaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: _secondaryColor,
                    size: 36,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Nom client
                Text(
                  order.clientName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Adresse
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: _textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        order.deliveryLocation.adresse,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 28),
                
                // Instruction
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _secondaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _secondaryColor.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: _secondaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Demandez le code OTP au client",
                          style: TextStyle(
                            fontSize: 15,
                            color: _secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Champ OTP
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 4,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: _secondaryColor,
                    letterSpacing: 12,
                    fontFamily: 'Monospace',
                  ),
                  decoration: InputDecoration(
                    hintText: "• • • •",
                    hintStyle: TextStyle(
                      color: _borderColor,
                      fontSize: 28,
                      letterSpacing: 12,
                    ),
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _borderColor, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: _secondaryColor,
                        width: 2.5,
                      ),
                    ),
                    filled: true,
                    fillColor: _cardColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textSecondary,
                          side: BorderSide(
                            color: _borderColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Annuler",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_controller.text == order.otp) {
                            setState(() {
                              order.status = OrderStatus.LIVREE;
                            });
                            Navigator.pop(context);
                            _showSuccessDialog(order.clientName);
                          } else {
                            _showErrorSnackBar("Code OTP incorrect");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _secondaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Valider",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String clientName) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône succès
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _successColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _successColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: _successColor,
                    size: 40,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  "Livraison réussie !",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  "Merci $clientName",
                  style: TextStyle(
                    fontSize: 16,
                    color: _textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _successColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Continuer",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  @override
Widget build(BuildContext context) {
  final deliveredCount = _localOrders.where((o) => o.status == OrderStatus.LIVREE).length;
  final remainingCount = _localOrders.length - deliveredCount;
  final double progressPercentage = _localOrders.isEmpty ? 0 : (deliveredCount / _localOrders.length);

  return Scaffold(
    backgroundColor: _backgroundColor,
    appBar: AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: _textPrimary,
        ),
      ),
      title: Text(
        "Tournée active",
        style: TextStyle(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeliveryMapScreen(batch: widget.batch),
              ),
            );
          },
          icon: Icon(
            Icons.map_outlined,
            color: _secondaryColor,
          ),
        ),
      ],
    ),
    body: Column(
      children: [
        // En-tête avec statistiques
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardColor,
            border: Border(
              bottom: BorderSide(color: _borderColor, width: 1),
            ),
          ),
          child: Column(
            children: [
              // ID du lot
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _secondaryColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.local_shipping_rounded,
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
                            "Lot ${widget.batch.id}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: _textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.batch.quartier,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Barre de progression
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Progression de la tournée",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        "${(progressPercentage * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progressPercentage,
                      minHeight: 10,
                      backgroundColor: _borderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(_secondaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$deliveredCount livré${deliveredCount > 1 ? 's' : ''}",
                        style: TextStyle(
                          fontSize: 13,
                          color: _successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "$remainingCount restant${remainingCount > 1 ? 's' : ''}",
                        style: TextStyle(
                          fontSize: 13,
                          color: _warningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Liste des commandes
        Expanded(
          child: _localOrders.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _localOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = _localOrders[index];
                    final isDelivered = order.status == OrderStatus.LIVREE;
                    
                    return _buildOrderCard(order, isDelivered);
                  },
                ),
        ),
      ],
    ),
  );
}

  Widget _buildOrderCard(Order order, bool isDelivered) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDelivered 
              ? _successColor.withOpacity(0.2) 
              : _borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: !isDelivered ? () => _verifyOtp(order) : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icône de statut
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDelivered 
                        ? _successColor.withOpacity(0.1) 
                        : _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDelivered 
                        ? Icons.check_rounded 
                        : Icons.pending_rounded,
                    color: isDelivered 
                        ? _successColor 
                        : _primaryColor,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.clientName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_iphone_rounded,
                            size: 14,
                            color: _textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.clientPhone,
                            style: TextStyle(
                              fontSize: 14,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: _textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              order.deliveryLocation.adresse,
                              style: TextStyle(
                                fontSize: 14,
                                color: _textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Bouton d'action
                if (isDelivered)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _successColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: _successColor,
                      size: 20,
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _verifyOtp(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Valider",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: _borderColor, width: 1.5),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 60,
              color: _successColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Tournée terminée !",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Toutes les commandes ont été livrées avec succès",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeliveryMapScreen(batch: widget.batch),
                ),
              );
            },
            icon: Icon(
              Icons.map_outlined,
              color: Colors.white,
            ),
            label: const Text(
              "Voir le parcours",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _secondaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}