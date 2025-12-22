import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/order_model.dart';
import '../../models/batch_model.dart';
import '../../core/enums.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Charte graphique
  static const Color _primaryColor = Color(0xFFEE8E42); // Orange
  static const Color _secondaryColor = Color(0xFF23529C); // Bleu
  static const Color _backgroundColor = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _cardColor = Color(0xFFF9FAFB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _infoColor = Color(0xFF3B82F6);
  static const Color _dangerColor = Color(0xFFEF4444);

  // Fonction de "Batching Automatique"
  void _runAutoBatching() async {
    // Afficher un indicateur de chargement
    bool isLoading = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: _secondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Optimisation en cours...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Regroupement des commandes par proximité géographique",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Simuler un traitement
    await Future.delayed(const Duration(milliseconds: 1500));
    Navigator.pop(context); // Fermer le dialog de chargement

    // 1. On récupère les commandes qui n'ont pas encore de lot
    List<Order> pendingOrders = MockData.orders
        .where(
          (o) =>
              o.status == OrderStatus.EN_ATTENTE_DE_LIVREUR &&
              (o.batchId == null),
        )
        .toList();

    if (pendingOrders.isEmpty) {
      _showSnackbar(
        "Aucune commande en attente de groupage",
        _warningColor,
        Icons.info_outline_rounded,
      );
      return;
    }

    // 2. Logique simplifiée : on groupe par quartier
    Map<String, List<String>> groups = {};
    for (var order in pendingOrders) {
      groups
          .putIfAbsent(order.deliveryLocation.quartier, () => [])
          .add(order.id);
    }

    // 3. Création des nouveaux lots dans MockData
    int createdCount = 0;
    groups.forEach((quartier, orderIds) {
      final newBatch = Batch(
        id: "BATCH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
        quartier: quartier,
        orderIds: orderIds,
        deliveries: pendingOrders.where((o) => orderIds.contains(o.id)).toList(),
        status: BatchStatus.DISPONIBLE,
        vendorName: "Multi-Vendeurs",
        deliveryFee: 1500.0 + (orderIds.length * 500),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      MockData.batches.add(newBatch);
      createdCount++;
    });

    setState(() {});
    _showBatchingResult(createdCount, pendingOrders.length);
  }

  void _showBatchingResult(int batchCount, int orderCount) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
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
                    Icons.auto_awesome_rounded,
                    color: _successColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Optimisation réussie !",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "$batchCount nouveau${batchCount > 1 ? 'x' : ''} lot${batchCount > 1 ? 's' : ''} créé${batchCount > 1 ? 's' : ''}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: _textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$orderCount commande${orderCount > 1 ? 's' : ''} regroupée${orderCount > 1 ? 's' : ''} par proximité géographique",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
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
                      backgroundColor: _secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Continuer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  void _showSnackbar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalOrders = MockData.orders.length;
    int pendingBatch = MockData.orders.where((o) => o.batchId == null).length;
    int activeBatches = MockData.batches
        .where((b) => b.status == BatchStatus.EN_COURS)
        .length;
    int availableBatches = MockData.batches
        .where((b) => b.status == BatchStatus.DISPONIBLE)
        .length;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tableau de bord",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              "Administration YOBULMA",
              style: TextStyle(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_outlined,
              color: _textSecondary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cartes de statistiques
            Text(
              "Vue d'ensemble",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  title: "Commandes totales",
                  value: totalOrders.toString(),
                  icon: Icons.shopping_bag_outlined,
                  color: _secondaryColor,
                  trend: "+12%",
                ),
                _buildStatCard(
                  title: "À regrouper",
                  value: pendingBatch.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: _warningColor,
                  trend: pendingBatch > 5 ? "Urgent" : "Normal",
                  isUrgent: pendingBatch > 5,
                ),
                _buildStatCard(
                  title: "Lots disponibles",
                  value: availableBatches.toString(),
                  icon: Icons.inventory_2_outlined,
                  color: _successColor,
                  trend: "Prêts",
                ),
                _buildStatCard(
                  title: "Lots actifs",
                  value: activeBatches.toString(),
                  icon: Icons.local_shipping_outlined,
                  color: _infoColor,
                  trend: "En cours",
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section Intelligence Artificielle
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _secondaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _secondaryColor.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.auto_awesome_mosaic_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Optimisation automatique",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Notre algorithme analyse les commandes en attente et les regroupe automatiquement par proximité géographique pour optimiser les tournées des livreurs.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _runAutoBatching,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: _primaryColor.withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 22),
                          SizedBox(width: 12),
                          Text(
                            "Lancer l'optimisation",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Liste des lots récents
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Lots récents",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Action pour voir tous les lots
                  },
                  child: Text(
                    "Voir tout",
                    style: TextStyle(
                      color: _secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Liste des lots
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: MockData.batches.length > 3 ? 3 : MockData.batches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final batch = MockData.batches[index];
                final orderCount = batch.orderIds.length;
                
                return _buildBatchCard(batch, orderCount);
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isUrgent ? _dangerColor.withOpacity(0.1) : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUrgent ? _dangerColor.withOpacity(0.2) : color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isUrgent ? _dangerColor : color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(Batch batch, int orderCount) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_shipping_rounded,
              color: _secondaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lot ${batch.id}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
                      batch.quartier,
                      style: TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: _textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$orderCount colis",
                      style: TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: batch.status == BatchStatus.DISPONIBLE
                  ? _successColor.withOpacity(0.1)
                  : _warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: batch.status == BatchStatus.DISPONIBLE
                    ? _successColor.withOpacity(0.2)
                    : _warningColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Text(
              batch.status == BatchStatus.DISPONIBLE ? "Disponible" : "En cours",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: batch.status == BatchStatus.DISPONIBLE
                    ? _successColor
                    : _warningColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}