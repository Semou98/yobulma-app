import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yoboulma_app/models/location_model.dart';
import 'package:yoboulma_app/screens/livreur/active_delivery_screen.dart';
import '../../models/batch_model.dart';
import '../../services/api_service.dart';

class BatchDetailScreen extends StatefulWidget {
  final Batch batch;
  const BatchDetailScreen({super.key, required this.batch});

  @override
  State<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchDetailScreen> {
  final ApiService _apiService = ApiService();
  List<LatLng> _points = [];
  List<LatLng> _otherSegments = [];
  bool _loading = true;
  String _distance = "0";
  double _estimatedTime = 0;

  // Charte graphique
  static const Color _primaryColor = Color(0xFFEE8E42);
  static const Color _secondaryColor = Color(0xFF23529C);
  static const Color _backgroundColor = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  // --- LOGIQUE API (Inchangée) ---
  void _loadItinerary() async {
    try {
      final data = await _apiService.getOptimalRoute(
        Location(
          latitude: 14.6928,
          longitude: -17.4467,
          quartier: "Départ",
          adresse: "Ma Position",
        ),
        widget.batch.deliveries,
      );
      final segments = _apiService.extractRouteSegments(data);

      setState(() {
        _points = segments['first'] ?? [];
        _otherSegments = segments['others'] ?? [];
        double distMeters = 0;
        if (data['steps'] != null && data['steps'] is List) {
          final steps = data['steps'] as List;
          if (steps.isNotEmpty) {
            distMeters =
                steps[0]['distance_m']?.toDouble() ??
                steps[0]['distance']?.toDouble() ??
                0;
          }
        }
        _distance = (distMeters / 1000).toStringAsFixed(1);
        _estimatedTime = (distMeters / 1000) * 2;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _points = [LatLng(14.699, -17.450), LatLng(14.715, -17.467)];
        _distance = "3.3";
        _estimatedTime = 40;
        _loading = false;
      });
    }
  }

  // --- NOUVELLES FONCTIONS POUR L'AFFICHAGE DES DÉTAILS ---

  void _showBatchInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Informations du Lot",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.inventory_2_outlined,
                  value: "${widget.batch.orderCount}",
                  label: "Colis",
                  color: _primaryColor,
                ),
                _buildStatItem(
                  icon: Icons.flag_outlined,
                  value: _distance,
                  label: "km",
                  color: _secondaryColor,
                ),
                _buildStatItem(
                  icon: Icons.timer_outlined,
                  value: "${_estimatedTime.toInt()}",
                  label: "min",
                  color: _successColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeliveryPoints() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Points de livraison",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.batch.deliveries.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final delivery = widget.batch.deliveries[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _primaryColor.withOpacity(0.1),
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(color: _primaryColor),
                      ),
                    ),
                    title: Text(
                      delivery.clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(delivery.deliveryLocation.adresse),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
        ),
        title: Text(
          "Lot #${widget.batch.id}",
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Bouton Infos Lot
          IconButton(
            icon: const Icon(
              Icons.info_outline_rounded,
              color: _secondaryColor,
            ),
            onPressed: _showBatchInfo,
            tooltip: "Détails du lot",
          ),
          // Bouton Liste des points
          IconButton(
            icon: const Icon(
              Icons.format_list_bulleted_rounded,
              color: _secondaryColor,
            ),
            onPressed: _showDeliveryPoints,
            tooltip: "Points de livraison",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(14.716, -17.467),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_points.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _points,
                      color: _primaryColor,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              if (_otherSegments.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _otherSegments,
                      color: _secondaryColor,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                    ),
                  ],
                ),
            ],
          ),

          // Bouton d'action flottant en bas
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _showSuccess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded),
                    SizedBox(width: 12),
                    Text(
                      "Accepter la tournée",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: _secondaryColor),
            ),
        ],
      ),
    );
  }

  // --- WIDGET STAT ITEM (Réutilisé pour le BottomSheet) ---
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _textSecondary),
        ),
      ],
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Tournée acceptée !"),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveDeliveryScreen(batch: widget.batch),
        ),
      );
    });
  }
}
