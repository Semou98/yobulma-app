import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yoboulma_app/core/enums.dart'; 
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
            distMeters = steps[0]['distance_m']?.toDouble() ??
                steps[0]['distance']?.toDouble() ?? 0;
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
        title: Text("Lot #${widget.batch.id}", 
            style: const TextStyle(color: _textPrimary, fontWeight: FontWeight.bold)),
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
                userAgentPackageName: 'com.yoboulma.app',
              ),
              // Trajet principal (Ligne pleine)
              if (_points.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _points, 
                      color: _primaryColor, 
                      strokeWidth: 5,
                    ),
                  ],
                ),
              // Trajet secondaire (Ligne plus fine et transparente pour éviter les erreurs de pointillés)
              if (_otherSegments.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _otherSegments, 
                      color: _secondaryColor.withOpacity(0.4), 
                      strokeWidth: 3,
                    ),
                  ],
                ),
            ],
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _acceptTournee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded),
                    SizedBox(width: 12),
                    Text("Accepter la tournée", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

          if (_loading)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(child: CircularProgressIndicator(color: _secondaryColor)),
            ),
        ],
      ),
    );
  }

  void _acceptTournee() async {
    // Mise à jour de l'état avec l'enum
    setState(() {
      widget.batch.status = BatchStatus.EN_COURS; 
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tournée activée !"), 
        backgroundColor: _successColor, 
        behavior: SnackBarBehavior.floating
      ),
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveDeliveryScreen(batch: widget.batch),
      ),
    );

    // Retour à la liste si terminé
    if (result == 'completed') {
      if (mounted) Navigator.pop(context, 'completed');
    }
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: _textSecondary)),
      ],
    );
  }
}