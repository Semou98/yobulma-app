import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/auth/login_screen.dart';
import 'package:yoboulma_app/services/auth_service.dart';
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
  // --- ÉTATS ---
  String _userName = "Utilisateur";
  String _userInitials = "U";

  // --- CHARTE GRAPHIQUE ---
  static const Color _primaryOrange = Color(0xFFEE8E42);
  static const Color _secondaryBlue = Color(0xFF23529C);
  static const Color _bgColor = Colors.white;
  static const Color _textMain = Color(0xFF111827);
  static const Color _textSub = Color(0xFF6B7280);
  static const Color _border = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Récupère le nom utilisateur depuis le service d'authentification
  Future<void> _loadUserInfo() async {
    final user = await AuthService.getUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user.name;
        List<String> names = user.name.trim().split(" ");
        _userInitials = names.length >= 2 
            ? (names[0][0] + names[1][0]).toUpperCase() 
            : names[0][0].toUpperCase();
      });
    }
  }

  // Déconnexion avec vidage de la pile de navigation
  void _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final myOrders = MockData.orders.where((o) => o.vendeurId == 'vendeur-001').toList();

    return PopScope(
      canPop: false, // Empêche le retour sauvage vers le login
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            backgroundColor: _bgColor,
            elevation: 0,
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bonjour, $_userName", 
                  style: const TextStyle(fontSize: 13, color: _textSub, fontWeight: FontWeight.w500)),
                const Text("Mes expéditions", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _textMain)),
              ],
            ),
            actions: [
              // MENU PROFIL À DROITE
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'logout') _handleLogout();
                  },
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold, color: _textMain)),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                          SizedBox(width: 12),
                          Text("Déconnecter", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _primaryOrange.withOpacity(0.3), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: _secondaryBlue,
                      child: Text(_userInitials, 
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: TabBar(
                labelColor: _secondaryBlue,
                unselectedLabelColor: _textSub,
                indicatorColor: _primaryOrange,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: "En attente"),
                  Tab(text: "En cours"),
                  Tab(text: "Livrées"),
                ],
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
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const CreateOrderScreen())
            ).then((_) => setState(() {})),
            backgroundColor: _secondaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            label: const Text("Envoyer un colis", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> allOrders, OrderStatus status) {
    final filtered = allOrders.where((o) => o.status == status).toList();
    if (filtered.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildOrderCard(filtered[index]),
    );
  }

  Widget _buildOrderCard(Order order) {
    // Correction de l'erreur RangeError : substring sécurisé
    final String displayId = order.id.length > 8 ? order.id.substring(0, 8) : order.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("#$displayId", style: const TextStyle(fontWeight: FontWeight.bold, color: _secondaryBlue)),
                  _buildStatusBadge(order.status),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.person_outline, color: _secondaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(order.deliveryLocation.adresse, 
                          style: const TextStyle(color: _textSub, fontSize: 12),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: _primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(order.otp, style: const TextStyle(color: _primaryOrange, fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color = status == OrderStatus.LIVREE ? Colors.green : (status == OrderStatus.EN_COURS_DE_LIVRAISON ? Colors.blue : _primaryOrange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.name.split('.').last.replaceAll('_', ' '), 
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[200]),
          const SizedBox(height: 10),
          Text("Aucun colis trouvé", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}