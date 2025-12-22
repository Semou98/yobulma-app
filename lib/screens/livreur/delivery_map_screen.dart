import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yoboulma_app/models/location_model.dart';
import 'package:yoboulma_app/services/api_service.dart';
import '../../models/batch_model.dart';

class DeliveryMapScreen extends StatefulWidget {
  final Batch batch;
  const DeliveryMapScreen({super.key, required this.batch});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  final ApiService _apiService = ApiService();
  final MapController _mapController = MapController();
  List<LatLng> _firstSegment = [];
  List<LatLng> _otherSegments = [];
  bool _isLoading = true;
  bool _showInstructions = true;

  static const Color _primaryColor = Color(0xFFEE8E42); 
  static const Color _secondaryColor = Color(0xFF23529C); 
  static const Color _backgroundColor = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    // Utilisation d'un callback pour attendre que la carte soit prête
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOptimizedRoute();
    });
  }

  Future<void> _loadOptimizedRoute() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final courierPos = Location(
        latitude: 14.6928,
        longitude: -17.4467,
        quartier: "Départ",
        adresse: "Ma Position",
      );

      final response = await _apiService.getOptimalRoute(
        courierPos,
        widget.batch.deliveries,
      );

      final segments = _apiService.extractRouteSegments(response);

      if (mounted) {
        setState(() {
          _firstSegment = segments['first'] ?? [];
          _otherSegments = segments['others'] ?? [];
          _isLoading = false;
        });
        _fitRoute();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar("Erreur lors du calcul de l'itinéraire");
      }
    }
  }

  void _fitRoute() {
    final allPoints = [..._firstSegment, ..._otherSegments];
    if (allPoints.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(allPoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(70.0)),
      );
    }
  }

  void _centerOnUser() {
    _mapController.move(const LatLng(14.6928, -17.4467), 15.0);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tournée #${widget.batch.id}", 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
            Text(widget.batch.quartier, 
              style: const TextStyle(fontSize: 12, color: _textSecondary)),
          ],
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(14.6928, -17.4467),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yoboulma.app',
              ),
              if (_firstSegment.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(points: _firstSegment, color: _primaryColor, strokeWidth: 5.0),
                  ],
                ),
              if (_otherSegments.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _otherSegments, 
                      color: _secondaryColor.withOpacity(0.5), 
                      strokeWidth: 3.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Position Livreurs
                  Marker(
                    point: const LatLng(14.6928, -17.4467),
                    width: 40, height: 40,
                    child: const Icon(Icons.directions_bike, color: _secondaryColor, size: 30),
                  ),
                  // Points de livraisons
                  ...widget.batch.deliveries.asMap().entries.where((e) => 
                      e.value.deliveryLocation.latitude != null).map((entry) {
                    final index = entry.key + 1;
                    final order = entry.value;
                    return Marker(
                      point: LatLng(order.deliveryLocation.latitude!, order.deliveryLocation.longitude!),
                      width: 45, height: 45,
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(6),
                            child: Text("$index", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Boutons de contrôle (Positionnés au-dessus du panneau blanc)
          Positioned(
            bottom: 180, 
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "fit",
                  onPressed: _fitRoute,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.zoom_out_map, color: _secondaryColor),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "gps",
                  onPressed: _centerOnUser,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: _secondaryColor),
                ),
              ],
            ),
          ),

          // Panneau d'informations du bas
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ordre de passage", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.batch.deliveries.length,
                      itemBuilder: (context, index) {
                        final d = widget.batch.deliveries[index];
                        return Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: _borderColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${index + 1}. ${d.clientName}", 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(d.deliveryLocation.adresse, 
                                style: const TextStyle(fontSize: 11, color: _textSecondary),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(color: Colors.white60, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}