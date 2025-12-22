import 'package:flutter/material.dart';
import 'package:yoboulma_app/models/batch_model.dart';
import '../../data/mock_data.dart';
import 'batch_detail_screen.dart';

class LivreurBatchesListScreen extends StatefulWidget {
  const LivreurBatchesListScreen({super.key});

  @override
  State<LivreurBatchesListScreen> createState() =>
      _LivreurBatchesListScreenState();
}

class _LivreurBatchesListScreenState extends State<LivreurBatchesListScreen> {
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

  List<Batch> activeBatches = MockData.batches;
  bool _isRefreshing = false;

  Future<void> _refreshBatches() async {
    setState(() => _isRefreshing = true);
    // Simulation d'un rafraîchissement
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      activeBatches = MockData.batches;
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              "Tournées disponibles",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              "${activeBatches.length} lot${activeBatches.length > 1 ? 's' : ''} à récupérer",
              style: TextStyle(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refreshBatches,
            icon: Icon(
              Icons.refresh_rounded,
              color: _secondaryColor,
            ),
          ),
        ],
      ),
      body: _isRefreshing
          ? _buildLoadingState()
          : activeBatches.isEmpty
              ? _buildEmptyState()
              : _buildBatchesList(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: _secondaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Chargement des tournées...",
            style: TextStyle(
              fontSize: 16,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: _refreshBatches,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
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
                    Icons.inbox_outlined,
                    size: 60,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Aucune tournée disponible",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Les nouvelles tournées apparaîtront ici lorsqu'elles seront créées",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _refreshBatches,
                  icon: Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text(
                    "Actualiser",
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
          ),
        ),
      ),
    );
  }

  Widget _buildBatchesList() {
    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: _refreshBatches,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: activeBatches.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final batch = activeBatches[index];
          final deliveryCount = batch.orderIds.length;
          final hasOrders = deliveryCount > 0;
          
          return _buildBatchCard(batch, hasOrders, deliveryCount);
        },
      ),
    );
  }

  Widget _buildBatchCard(Batch batch, bool hasOrders, int deliveryCount) {
    return GestureDetector(
      onTap: () {
        if (hasOrders) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BatchDetailScreen(batch: batch),
            ),
          );
        } else {
          _showEmptyBatchSnackbar();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasOrders ? _borderColor : _warningColor.withOpacity(0.3),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec quartier et statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: hasOrders 
                                    ? _secondaryColor.withOpacity(0.1) 
                                    : _warningColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                hasOrders 
                                    ? Icons.local_shipping_rounded 
                                    : Icons.error_outline_rounded,
                                color: hasOrders 
                                    ? _secondaryColor 
                                    : _warningColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Lot ${batch.id}",
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
                                      Flexible(
                                        child: Text(
                                          batch.quartier,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _textSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                      if (!hasOrders)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _warningColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "Vide",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _warningColor,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Statistiques
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.inventory_2_outlined,
                          value: deliveryCount.toString(),
                          label: "Colis",
                          color: hasOrders ? _primaryColor : _textSecondary,
                        ),
                        _buildStatItem(
                          icon: Icons.store_outlined,
                          value: batch.vendorName,
                          label: "Vendeur",
                          color: hasOrders ? _secondaryColor : _textSecondary,
                          isText: true,
                        ),
                        _buildStatItem(
                          icon: Icons.schedule_outlined,
                          value: "${(deliveryCount * 15).toString()} min",
                          label: "Estimation",
                          color: hasOrders ? _successColor : _textSecondary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bouton d'action
                  Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: hasOrders 
                          ? _secondaryColor.withOpacity(0.1) 
                          : _borderColor,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hasOrders ? "Voir les détails" : "Lot indisponible",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: hasOrders 
                                  ? _secondaryColor 
                                  : _textSecondary,
                            ),
                          ),
                          if (hasOrders) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: _secondaryColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Badge de nouveau si le lot est récent
            if (batch.createdAt.isAfter(
              DateTime.now().subtract(const Duration(hours: 24)),
            ))
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Nouveau",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isText = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: isText ? 12 : 14,
            fontWeight: isText ? FontWeight.w600 : FontWeight.w800,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showEmptyBatchSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text("Ce lot ne contient aucune commande"),
            ),
          ],
        ),
        backgroundColor: _warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}