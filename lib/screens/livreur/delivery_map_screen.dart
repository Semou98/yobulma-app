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

  // Charte graphique
  static const Color _primaryColor = Color(0xFFEE8E42); // Orange
  static const Color _secondaryColor = Color(0xFF23529C); // Bleu
  static const Color _backgroundColor = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _loadOptimizedRoute();
  }

  Future<void> _loadOptimizedRoute() async {
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

        // Ajustement automatique du zoom
        _fitRoute();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar("Impossible de charger l'itinéraire optimisé");
      }
    }
  }

  void _fitRoute() {
    final allPoints = [..._firstSegment, ..._otherSegments];
    if (allPoints.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(allPoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80.0)),
      );
    }
  }

  void _centerOnUser() {
    _mapController.move(
      const LatLng(14.6928, -17.4467),
      15.0,
    );
  }

  void _centerOnRoute() {
    _fitRoute();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
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
          icon: Icon(
            Icons.arrow_back_rounded,
            color: _textPrimary,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lot ${widget.batch.id}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            Text(
              widget.batch.quartier,
              style: TextStyle(
                fontSize: 13,
                color: _textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _secondaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Carte
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(14.7000, -17.4500),
              initialZoom: 13.0,
            ),
            children: [
              // Tuiles OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yoboulma.app',
              ),

              // Itinéraire optimisé
              if (_firstSegment.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _firstSegment,
                      color: _primaryColor,
                      strokeWidth: 5.0,
                      borderStrokeWidth: 2,
                      borderColor: Colors.white,
                      strokeCap: StrokeCap.round,
                    ),
                  ],
                ),

              // Segments secondaires
              if (_otherSegments.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _otherSegments,
                      color: _secondaryColor.withOpacity(0.8),
                      strokeWidth: 4.0,
                      borderStrokeWidth: 1,
                      borderColor: Colors.white,
                      strokeCap: StrokeCap.round,
                    ),
                  ],
                ),

              // Marqueurs des points de livraison
              MarkerLayer(
                markers: [
                  // Marqueur du livreur
                  Marker(
                    point: const LatLng(14.6928, -17.4467),
                    width: 60,
                    height: 60,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _secondaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_bike_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "Moi",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Marqueurs des livraisons
                  ...widget.batch.deliveries.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final order = entry.value;
                    return Marker(
                      point: LatLng(
                        order.deliveryLocation.latitude!,
                        order.deliveryLocation.longitude!,
                      ),
                      width: 70,
                      height: 70,
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                index.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              order.clientName.split(' ')[0],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Instructions au premier chargement
          if (_showInstructions && !_isLoading)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => setState(() => _showInstructions = false),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: _secondaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Itinéraire optimisé",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () =>
                                setState(() => _showInstructions = false),
                            icon: Icon(
                              Icons.close_rounded,
                              color: _textSecondary,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Les points numérotés représentent l'ordre optimal de livraison",
                        style: TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Trajet principal",
                            style: TextStyle(
                              fontSize: 13,
                              color: _textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _secondaryColor.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Trajets secondaires",
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
              ),
            ),

          // Panneau de contrôle
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                // Bouton centrer sur l'itinéraire
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _centerOnRoute,
                    icon: Icon(
                      Icons.zoom_out_map_rounded,
                      color: _secondaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Bouton centrer sur ma position
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _centerOnUser,
                    icon: Icon(
                      Icons.my_location_rounded,
                      color: _secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Informations en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Points de livraison",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _secondaryColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          "${widget.batch.deliveries.length} adresses",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.batch.deliveries
                          .take(5)
                          .map((delivery) {
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _backgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                delivery.clientName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  delivery.deliveryLocation.adresse,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadOptimizedRoute,
        backgroundColor: _secondaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.refresh_rounded),
      ),
    );
  }
}