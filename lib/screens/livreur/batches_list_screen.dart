import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // Pour le calcul de distance
import 'package:yoboulma_app/models/batch_model.dart';
import 'package:yoboulma_app/core/enums.dart';
import '../../data/mock_data.dart';
import 'batch_detail_screen.dart';

class LivreurBatchesListScreen extends StatefulWidget {
  const LivreurBatchesListScreen({super.key});

  @override
  State<LivreurBatchesListScreen> createState() =>
      _LivreurBatchesListScreenState();
}

class _LivreurBatchesListScreenState extends State<LivreurBatchesListScreen> {
  static const Color _primaryColor = Color(0xFFEE8E42);
  static const Color _secondaryColor = Color(0xFF23529C);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);

  // Position fictive du livreur (ex: Centre de Dakar)
  final LatLng _currentCourierPos = const LatLng(14.6928, -17.4467);

  List<Batch> nearbyBatches = [];

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  // --- LOGIQUE DE FILTRAGE PAR PROXIMITÉ (LES 4 PLUS PROCHES) ---
  void _loadBatches() {
    final Distance distanceCalculator = const Distance();

    // 1. Filtrer par statut (Disponible ou En cours)
    List<Batch> filtered = MockData.batches.where((b) {
      return b.status == BatchStatus.DISPONIBLE ||
          b.status == BatchStatus.EN_COURS;
    }).toList();

    // 2. Calculer la distance pour chaque lot et trier
    List<Map<String, dynamic>> batchWithDistance = filtered.map((batch) {
      double dist = 0;
      if (batch.deliveries.isNotEmpty) {
        // Distance entre le livreur et la première livraison du lot
        dist = distanceCalculator.as(
          LengthUnit.Kilometer,
          _currentCourierPos,
          LatLng(
            batch.deliveries.first.deliveryLocation.latitude ?? 0,
            batch.deliveries.first.deliveryLocation.longitude ?? 0,
          ),
        );
      }
      return {'batch': batch, 'distance': dist};
    }).toList();

    // Trier du plus proche au plus loin
    batchWithDistance.sort((a, b) => a['distance'].compareTo(b['distance']));

    setState(() {
      // 3. Prendre uniquement les 4 plus proches
      nearbyBatches = batchWithDistance
          .take(4)
          .map((e) => e['batch'] as Batch)
          .toList();
    });
  }

  Future<void> _refreshBatches() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _loadBatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tournées à proximité",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _textPrimary,
              ),
            ),
            Text(
              "Les 4 lots les plus proches de vous",
              style: TextStyle(
                fontSize: 13,
                color: _textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBatches,
        color: _primaryColor,
        child: nearbyBatches.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: nearbyBatches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    _buildBatchCard(nearbyBatches[index]),
              ),
      ),
    );
  }

  Widget _buildBatchCard(Batch batch) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BatchDetailScreen(batch: batch),
          ),
        );

        if (result == 'completed') {
          _loadBatches();
          _showSuccessSnackbar();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: _secondaryColor.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _secondaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
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
                        "Lot #${batch.id}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        batch.quartier,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${batch.deliveryFee.toInt()} FCFA",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _primaryColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(batch.status),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: _textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${batch.orderIds.length} colis",
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      "Détails",
                      style: TextStyle(
                        color: _secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: _secondaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BatchStatus status) {
    bool isAvailable = status == BatchStatus.DISPONIBLE;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isAvailable ? Colors.green : _primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isAvailable ? "Disponible" : "En cours",
        style: TextStyle(
          color: isAvailable ? Colors.green : _primaryColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 80,
              color: _textSecondary.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            const Text(
              "Aucun lot à proximité",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tirez vers le bas pour actualiser",
              style: TextStyle(color: _textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Tournée terminée avec succès !"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
