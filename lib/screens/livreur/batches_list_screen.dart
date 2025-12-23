import 'package:flutter/material.dart';
import 'package:yoboulma_app/models/batch_model.dart';
import 'package:yoboulma_app/services/auth_service.dart';
import '../../data/mock_data.dart';
import 'batch_detail_screen.dart';

class LivreurBatchesListScreen extends StatefulWidget {
  const LivreurBatchesListScreen({super.key});

  @override
  State<LivreurBatchesListScreen> createState() => _LivreurBatchesListScreenState();
}

class _LivreurBatchesListScreenState extends State<LivreurBatchesListScreen> {
  // --- CHARTE GRAPHIQUE ---
  final Color _primaryColor = const Color(0xFFEE8E42);
  final Color _secondaryColor = const Color(0xFF23529C);
  final Color _backgroundColor = const Color(0xFFF8F9FE);
  final Color _textPrimary = const Color(0xFF1A1C1E);
  final Color _textSecondary = const Color(0xFF74777F);
  final Color _cardColor = Colors.white;
  final Color _successColor = const Color(0xFF27AE60);

  List<Batch> activeBatches = [];
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      activeBatches = MockData.batches;
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Déconnexion", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Souhaitez-vous vraiment quitter votre session ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Rester", style: TextStyle(color: _secondaryColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Déconnecter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // APP BAR AVEC VOTRE LOGO
          SliverAppBar(
            expandedHeight: 110.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: _backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: _backgroundColor),
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LOGO DEPUIS LE CHEMIN SPÉCIFIÉ
                  Image.asset(
                    'lib/images/YOBULMA LOGO_Plan de travail 1.png',
                    height: 35, // Taille ajustée pour l'AppBar
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Text(
                      "YOBOULMA",
                      style: TextStyle(
                        color: _secondaryColor, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 18
                      ),
                    ),
                  ),
                  _buildHeaderAction(Icons.logout_rounded, _handleLogout, color: Colors.redAccent),
                ],
              ),
            ),
          ),

          // TITRE DE SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tableau de bord",
                    style: TextStyle(fontSize: 14, color: _textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Mes tournées",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textPrimary),
                  ),
                ],
              ),
            ),
          ),

          // LISTE DES TOURNEES
          activeBatches.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildModernBatchCard(activeBatches[index]),
                      childCount: activeBatches.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Icon(icon, color: color ?? _secondaryColor, size: 20),
      ),
    );
  }

  Widget _buildModernBatchCard(Batch batch) {
    final int count = batch.orderIds.length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _secondaryColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => BatchDetailScreen(batch: batch))
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        // ICONE DE MOTO (REPLACEMENT)
                        child: Icon(Icons.two_wheeler_rounded, color: _primaryColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "LOT #${batch.id}",
                              style: TextStyle(color: _textSecondary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              batch.quartier,
                              style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      _statusBadge(),
                    ],
                  ),
                  const Divider(height: 32, thickness: 0.8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat(Icons.inventory_2_rounded, "$count Colis"),
                      _buildMiniStat(Icons.store_rounded, batch.vendorName),
                      _buildMiniStat(Icons.timer_rounded, "${count * 10} min"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => BatchDetailScreen(batch: batch))
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _secondaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        "Détails de la tournée",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _successColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "DISPONIBLE",
        style: TextStyle(color: _successColor, fontWeight: FontWeight.w800, fontSize: 10),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _secondaryColor.withOpacity(0.6)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ICONE DE MOTO POUR L'ETAT VIDE
          Icon(Icons.motorcycle_rounded, size: 80, color: _textSecondary.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(
            "Aucune tournée assignée",
            style: TextStyle(color: _textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}