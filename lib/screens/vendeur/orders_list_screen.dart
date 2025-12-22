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
  // Charte graphique
  static const Color _primaryColor = Color(0xFFEE8E42); // Orange
  static const Color _secondaryColor = Color(0xFF23529C); // Bleu
  static const Color _backgroundColor = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _cardColor = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context) {
    // Filtrage des commandes du vendeur actuel (vendeur-001)
    final myOrders = MockData.orders
        .where((o) => o.vendeurId == 'vendeur-001')
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: _backgroundColor,
          elevation: 0,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mes expéditions",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "${myOrders.length} commande${myOrders.length > 1 ? 's' : ''} au total",
                style: TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              color: _backgroundColor,
              child: Column(
                children: [
                  TabBar(
                    labelColor: _primaryColor,
                    unselectedLabelColor: _textSecondary,
                    indicatorColor: _primaryColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.hourglass_top_rounded, size: 20),
                        text: "En attente",
                      ),
                      Tab(
                        icon: Icon(Icons.local_shipping_rounded, size: 20),
                        text: "En cours",
                      ),
                      Tab(
                        icon: Icon(Icons.check_circle_rounded, size: 20),
                        text: "Livrées",
                      ),
                    ],
                  ),
                  const Divider(height: 1, thickness: 1),
                ],
              ),
            ),
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
          icon: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_rounded,
              color: _secondaryColor,
              size: 18,
            ),
          ),
          label: const Text(
            "Nouvelle expédition",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          backgroundColor: _secondaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> allOrders, OrderStatus status) {
    final filteredOrders = allOrders.where((o) => o.status == status).toList();

    if (filteredOrders.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      color: _primaryColor,
      backgroundColor: _backgroundColor,
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: filteredOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildEmptyState(OrderStatus status) {
    String message;
    IconData icon;
    
    switch (status) {
      case OrderStatus.EN_ATTENTE_DE_LIVREUR:
        message = "Aucune commande en attente";
        icon = Icons.hourglass_empty_rounded;
        break;
      case OrderStatus.EN_COURS_DE_LIVRAISON:
        message = "Aucune commande en cours";
        icon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.LIVREE:
        message = "Aucune commande livrée";
        icon = Icons.check_circle_outline_rounded;
        break;
      default:
        message = "Aucune commande";
        icon = Icons.inventory_2_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: _borderColor, width: 1.5),
            ),
            child: Icon(
              icon,
              size: 40,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Les nouvelles commandes apparaîtront ici",
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(order: order),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec ID et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.id,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _secondaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Informations client
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: _secondaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        const SizedBox(height: 4),
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
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Adresse de livraison
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: _primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Livraison à",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textSecondary,
                            ),
                          ),
                          Text(
                            order.deliveryLocation.adresse,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              order.deliveryLocation.quartier,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Pied de carte avec OTP et date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _secondaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _secondaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.vpn_key_rounded,
                          size: 14,
                          color: _secondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "OTP: ${order.otp}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case OrderStatus.LIVREE:
        color = _successColor;
        text = "Livrée";
        icon = Icons.check_circle_rounded;
        break;
      case OrderStatus.EN_COURS_DE_LIVRAISON:
        color = _warningColor;
        text = "En cours";
        icon = Icons.local_shipping_rounded;
        break;
      case OrderStatus.EN_ATTENTE_DE_LIVREUR:
        color = _primaryColor;
        text = "En attente";
        icon = Icons.hourglass_top_rounded;
        break;
      default:
        color = _textSecondary;
        text = "Inconnu";
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (difference.inDays > 0) {
      return "Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}";
    } else if (difference.inHours > 0) {
      return "Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}";
    } else if (difference.inMinutes > 0) {
      return "Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}";
    } else {
      return "À l'instant";
    }
  }
}