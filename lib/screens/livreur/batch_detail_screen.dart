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
  static const Color _primaryColor = Color(0xFFEE8E42); // Orange
  static const Color _secondaryColor = Color(0xFF23529C); // Bleu
  static const Color _backgroundColor = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _cardColor = Color(0xFFF9FAFB);
  static const Color _successColor = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  void _loadItinerary() async {
    print("--- DÉBUT CHARGEMENT ITINÉRAIRE ---");
    print("Appel API pour les commandes: ${widget.batch.orderIds}");

    try {
      final data = await _apiService.getOptimalRoute(
        // Position fictive du livreur (à remplacer par le GPS réel plus tard)
        Location(
          latitude: 14.6928,
          longitude: -17.4467,
          quartier: "Départ",
          adresse: "Ma Position",
        ),
        widget.batch.deliveries,
      );

      print("JSON REÇU DE L'API: $data");

      // Utilisez la méthode CORRECTE de l'ApiService
      final segments = _apiService.extractRouteSegments(data);

      setState(() {
        _points = segments['first'] ?? [];
        _otherSegments = segments['others'] ?? [];

        print("Points du premier segment: ${_points.length}");
        print("Points des autres segments: ${_otherSegments.length}");

        // Calcul de la distance
        double distMeters = 0;
        if (data['steps'] != null && data['steps'] is List) {
          final steps = data['steps'] as List;
          print("Nombre d'étapes: ${steps.length}");

          if (steps.isNotEmpty) {
            // Essayez différents noms de clés pour la distance
            distMeters =
                steps[0]['distance_m']?.toDouble() ??
                steps[0]['distance']?.toDouble() ??
                0;
            print("Distance calculée: ${distMeters}m");
          }
        }

        _distance = (distMeters / 1000).toStringAsFixed(1);
        _estimatedTime = (distMeters / 1000) * 2; // Estimation: 2 min par km
        _loading = false;
      });

      print("--- CHARGEMENT RÉUSSI ---");
    } catch (e, stacktrace) {
      print("ERREUR API DÉTECTÉE: $e");
      print("DÉTAILS TECHNIQUES: $stacktrace");

      setState(() {
        // Points de démo en cas d'erreur
        _points = [
          LatLng(14.699, -17.450),
          LatLng(14.705, -17.455),
          LatLng(14.710, -17.460),
          LatLng(14.715, -17.467),
        ];
        _otherSegments = [];
        _distance = "3.3";
        _estimatedTime = 40; // 40 minutes pour la démo
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: _textPrimary),
        ),
        title: Text(
          "Détails du lot",
          style: TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Carte OpenStreetMap
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
              // Premier segment
              if (_points.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _points,
                      color: _primaryColor,
                      strokeWidth: 4,
                      borderStrokeWidth: 2,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              // Autres segments
              if (_otherSegments.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _otherSegments,
                      color: _secondaryColor,
                      strokeWidth: 3,
                      borderStrokeWidth: 1,
                      borderColor: Colors.white,
                      strokeCap: StrokeCap.round,
                    ),
                  ],
                ),
            ],
          ),

          // En-tête avec informations
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre du lot
                    Row(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lot ${widget.batch.id}",
                                style: TextStyle(
                                  fontSize: 18,
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
                                  Text(
                                    widget.batch.quartier,
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

                    const SizedBox(height: 20),

                    // Statistiques
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
                  ],
                ),
              ),
            ),
          ),

          // Section des points de livraison
          Positioned(
            bottom: 140,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.list_alt_outlined,
                          color: _secondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Points de livraison",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.batch.deliveries.take(3).map((delivery) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    delivery.clientName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  Text(
                                    delivery.deliveryLocation.adresse,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (widget.batch.deliveries.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "+ ${widget.batch.deliveries.length - 3} autres points...",
                          style: TextStyle(
                            fontSize: 13,
                            color: _textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bouton d'acceptation
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _secondaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  _showSuccess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 24,
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 22),
                    const SizedBox(width: 12),
                    const Text(
                      "Accepter la tournée",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Indicateur de chargement
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: _secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Chargement...",
                          style: TextStyle(fontSize: 12, color: _textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Tournée acceptée avec succès !",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );

    // Remplacer l'écran actuel par l'écran de livraison active
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
