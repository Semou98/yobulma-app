import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/vendeur/order_detail_screen.dart';
import 'package:yoboulma_app/services/auth_service.dart'; // Import pour logout
import 'package:yoboulma_app/screens/auth/login_screen.dart'; // Import pour redirection
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
  // Charte graphique
  static const Color _primaryColor = Color(0xFFEE8E42); 
  static const Color _secondaryColor = Color(0xFF23529C); 
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

  // Charger l'utilisateur pour filtrer les commandes par son ID réel
  void _loadUser() async {
    final user = await AuthService.getUser();
    setState(() {
      _currentUser = user;
    });
  }

  // Logique de déconnexion
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
    // Filtrage dynamique : Utilise l'ID de l'utilisateur connecté ou 'vendeur-001' par défaut
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
                  fontSize: 24,
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
            // Bouton de déconnexion ajouté ici
            IconButton(
              onPressed: () => _showLogoutDialog(),
              icon: const Icon(Icons.logout_rounded, color: _textSecondary),
              tooltip: "Déconnexion",
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              color: _backgroundColor,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: _primaryColor,
                    unselectedLabelColor: _textSecondary,
                    indicatorColor: _primaryColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    tabs: [
                      Tab(icon: Icon(Icons.hourglass_top_rounded, size: 20), text: "En attente"),
                      Tab(icon: Icon(Icons.local_shipping_rounded, size: 20), text: "En cours"),
                      Tab(icon: Icon(Icons.check_circle_rounded, size: 20), text: "Livrées"),
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
            ).then((_) => setState(() {})); 
          },
          icon: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.add_rounded, color: _secondaryColor, size: 18),
          ),
          label: const Text("Nouvelle expédition", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          backgroundColor: _secondaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment quitter l'application ?"),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: filteredOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildOrderCard(filteredOrders[index]),
      ),
    );
  }

  Widget _buildEmptyState(OrderStatus status) {
    IconData icon;
    String message;
    switch (status) {
      case OrderStatus.EN_ATTENTE_DE_LIVREUR: icon = Icons.hourglass_empty; message = "Aucune commande en attente"; break;
      case OrderStatus.EN_COURS_DE_LIVRAISON: icon = Icons.local_shipping_outlined; message = "Aucune livraison en cours"; break;
      case OrderStatus.LIVREE: icon = Icons.check_circle_outline; message = "Aucune commande livrée"; break;
      default: icon = Icons.inventory_2_outlined; message = "Liste vide";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: _textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textSecondary)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _secondaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(order.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _secondaryColor)),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(backgroundColor: _cardColor, child: Icon(Icons.person, color: _secondaryColor, size: 20)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(order.clientPhone, style: const TextStyle(color: _textSecondary, fontSize: 14)),
                  ],
                ),
              ],
            ),
            const Divider(height: 30),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: _primaryColor),
                const SizedBox(width: 8),
                Expanded(child: Text(order.deliveryLocation.adresse, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: _secondaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                  child: Text("OTP: ${order.otp}", style: const TextStyle(fontWeight: FontWeight.bold, color: _secondaryColor)),
                ),
                Text(_formatDate(order.createdAt), style: const TextStyle(color: _textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color = status == OrderStatus.LIVREE ? _successColor : (status == OrderStatus.EN_COURS_DE_LIVRAISON ? _warningColor : _primaryColor);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(status.name.split('.').last.replaceAll('_', ' '), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return "Il y a ${diff.inDays}j";
    if (diff.inHours > 0) return "Il y a ${diff.inHours}h";
    return "À l'instant";
  }
}