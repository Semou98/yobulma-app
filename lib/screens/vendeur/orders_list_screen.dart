import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/vendeur/order_detail_screen.dart';
import 'package:yoboulma_app/services/auth_service.dart';
import 'package:yoboulma_app/screens/auth/login_screen.dart';
import '../../data/mock_data.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../core/enums.dart';
import 'create_order_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  // Charte graphique unifiée
  static const Color _primaryColor = Color(0xFFEE8E42); // Orange Yobulma
  static const Color _secondaryColor = Color(0xFF23529C); // Bleu Yobulma
  static const Color _backgroundColor = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _cardColor = Color(0xFFF9FAFB);

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Charger l'utilisateur pour filtrer les commandes
  void _loadUser() async {
    final user = await AuthService.getUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrage : ID de l'utilisateur connecté ou fallback sur mock
    final String currentVendeurId = _currentUser?.id ?? 'vendeur-001';
    
    final myOrders = MockData.orders
        .where((o) => o.vendeurId == currentVendeurId)
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
              const Text(
                "Mes expéditions",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "${myOrders.length} commande${myOrders.length > 1 ? 's' : ''} au total",
                style: const TextStyle(fontSize: 13, color: _textSecondary),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => _showLogoutDialog(),
              icon: const Icon(Icons.logout_rounded, color: _textSecondary),
              tooltip: "Déconnexion",
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _borderColor, width: 1)),
              ),
              child: const TabBar(
                labelColor: _secondaryColor,
                unselectedLabelColor: _textSecondary,
                indicatorColor: _primaryColor,
                indicatorWeight: 3,
                labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: [
                  Tab(text: "En attente"),
                  Tab(text: "En cours"),
                  Tab(text: "Livrées"),
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
            ).then((value) {
              if (value == true) setState(() {}); 
            });
          },
          icon: const Icon(Icons.add_box_rounded, color: Colors.white),
          label: const Text("Envoyer un colis", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: _secondaryColor,
          elevation: 4,
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
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: filteredOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildOrderCard(filteredOrders[index]),
      ),
    );
  }

  Widget _buildEmptyState(OrderStatus status) {
    String message = "Rien à afficher ici";
    IconData icon = Icons.inventory_2_outlined;

    if (status == OrderStatus.EN_ATTENTE_DE_LIVREUR) message = "Aucun colis en attente";
    if (status == OrderStatus.EN_COURS_DE_LIVRAISON) message = "Aucun colis sur la route";
    if (status == OrderStatus.LIVREE) message = "Vous n'avez pas encore de livraisons terminées";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: _borderColor),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: _textSecondary, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: _secondaryColor),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person_pin_circle_rounded, color: _primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.clientName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: _textSecondary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.deliveryLocation.adresse,
                    style: const TextStyle(color: _textSecondary, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Code OTP: ${order.otp}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(color: _textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color = _primaryColor;
    String label = "En attente";

    if (status == OrderStatus.EN_COURS_DE_LIVRAISON) {
      color = _warningColor;
      label = "En cours";
    } else if (status == OrderStatus.LIVREE) {
      color = _successColor;
      label = "Livré";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) return "Il y a ${difference.inMinutes} min";
    if (difference.inHours < 24) return "Il y a ${difference.inHours} h";
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Déconnexion"),
        content: const Text("Souhaitez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            }, 
            child: const Text("Déconnexion", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}