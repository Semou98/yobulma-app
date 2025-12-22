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
  // Charte graphique centralisée
  static const Color _primaryColor = Color(0xFFEE8E42);
  static const Color _secondaryColor = Color(0xFF23529C);
  static const Color _backgroundColor = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _infoColor = Color(0xFF3B82F6);
  static const Color _dangerColor = Color(0xFFEF4444);

  int totalOrders = 0;
  int pendingBatch = 0;
  int activeBatches = 0;
  int availableBatches = 0;

  @override
  void initState() {
    super.initState();
    _calculateStatistics();
  }

  void _calculateStatistics() {
    setState(() {
      totalOrders = MockData.orders.length;
      pendingBatch = MockData.orders
          .where(
            (o) =>
                o.batchId == null &&
                o.status == OrderStatus.EN_ATTENTE_DE_LIVREUR,
          )
          .length;
      activeBatches = MockData.batches
          .where((b) => b.status == BatchStatus.EN_COURS)
          .length;
      availableBatches = MockData.batches
          .where((b) => b.status == BatchStatus.DISPONIBLE)
          .length;
    });
  }

  // --- LOGIQUE METIER ---

  Future<void> _runAutoBatching() async {
    // 1. Loader
    _showLoadingDialog();

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;
    Navigator.pop(context);

    // 2. Filtrage des commandes éligibles
    List<Order> eligibleOrders = MockData.orders
        .where(
          (o) =>
              o.status == OrderStatus.EN_ATTENTE_DE_LIVREUR &&
              o.batchId == null,
        )
        .toList();

    if (eligibleOrders.isEmpty) {
      _showSnackbar(
        "Aucune commande éligible pour le moment",
        _warningColor,
        Icons.info_outline,
      );
      return;
    }

    // 3. Algorithme de groupage par quartier
    Map<String, List<Order>> groups = {};
    for (var order in eligibleOrders) {
      groups.putIfAbsent(order.deliveryLocation.quartier, () => []).add(order);
    }

    int createdCount = 0;
    groups.forEach((quartier, ordersInGroup) {
      final orderIds = ordersInGroup.map((o) => o.id).toList();
      final batchId =
          "B-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

      // ... à l'intérieur de groups.forEach dans AdminDashboardScreen ...

      final newBatch = Batch(
        id: batchId,
        quartier: quartier,
        orderIds: orderIds,
        // deliveries: ordersInGroup, <--- SUPPRIMER CETTE LIGNE
        status: BatchStatus.DISPONIBLE,
        vendorName: "Multi-Vendeurs",
        deliveryFee: 1500.0 + (orderIds.length * 300),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Mise à jour des commandes pour lier le batchId
      for (var o in ordersInGroup) {
        o.batchId = batchId;
      }

      MockData.batches.insert(
        0,
        newBatch,
      ); // Insérer au début pour l'affichage "Récents"
      createdCount++;
    });

    _calculateStatistics();
    _showBatchingResult(createdCount, eligibleOrders.length);
  }

  // --- UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: _primaryColor,
        onRefresh: () async {
          _calculateStatistics();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Vue d'ensemble"),
              const SizedBox(height: 16),
              _buildStatsGrid(),
              const SizedBox(height: 32),
              _buildAIBanner(),
              const SizedBox(height: 32),
              _buildRecentBatchesHeader(),
              const SizedBox(height: 16),
              _buildBatchesList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tableau de bord",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _textPrimary,
            ),
          ),
          Text(
            "Administration YOBULMA",
            style: TextStyle(
              fontSize: 13,
              color: _textSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      children: [
        _buildStatCard(
          "Commandes",
          totalOrders.toString(),
          Icons.shopping_bag_outlined,
          _secondaryColor,
          "+4%",
        ),
        _buildStatCard(
          "À regrouper",
          pendingBatch.toString(),
          Icons.pending_actions_outlined,
          _warningColor,
          "Attente",
          isUrgent: pendingBatch > 3,
        ),
        _buildStatCard(
          "Lots Dispo",
          availableBatches.toString(),
          Icons.inventory_2_outlined,
          _successColor,
          "Prêts",
        ),
        _buildStatCard(
          "En cours",
          activeBatches.toString(),
          Icons.local_shipping_outlined,
          _infoColor,
          "Livreurs",
        ),
      ],
    );
  }

  Widget _buildAIBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_secondaryColor, Color(0xFF1A3E7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _secondaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: _primaryColor, size: 28),
              SizedBox(width: 12),
              Text(
                "Smart Batching",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Regroupez intelligemment vos commandes par proximité pour réduire les frais de livraison.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _runAutoBatching,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Lancer l'optimisation",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchesList() {
    if (MockData.batches.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: MockData.batches.length > 5 ? 5 : MockData.batches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildBatchCard(MockData.batches[index]),
    );
  }

  // --- HELPERS UI ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String trend, {
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent ? _dangerColor.withOpacity(0.3) : _borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (isUrgent)
                const Icon(
                  Icons.priority_high_rounded,
                  color: _dangerColor,
                  size: 18,
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: _textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(Batch batch) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _secondaryColor.withOpacity(0.1),
            child: const Icon(
              Icons.local_shipping_rounded,
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
                  "Lot #${batch.id}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "${batch.quartier} • ${batch.orderIds.length} commandes",
                  style: const TextStyle(color: _textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildStatusBadge(batch.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BatchStatus status) {
    bool isAvailable = status == BatchStatus.DISPONIBLE;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isAvailable ? _successColor : _warningColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isAvailable ? "Disponible" : "En cours",
        style: TextStyle(
          color: isAvailable ? _successColor : _warningColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const CircularProgressIndicator(color: _secondaryColor),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.layers_clear_outlined,
              size: 48,
              color: _textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              "Aucun lot généré",
              style: TextStyle(
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBatchesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle("Lots récents"),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Voir tout",
            style: TextStyle(color: _secondaryColor),
          ),
        ),
      ],
    );
  }

  // Fonctions de notification (Dialogues de succès, Snackbars, etc. déjà bien implémentées dans votre code original)
  void _showSnackbar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showBatchingResult(int batchCount, int orderCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: _successColor, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Optimisation terminée",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "$batchCount nouveaux lots créés pour $orderCount commandes.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }
}
