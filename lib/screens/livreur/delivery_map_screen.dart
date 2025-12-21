import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yoboulma_app/models/location_model.dart';
import 'package:yoboulma_app/services/api_service.dart';
import '../../models/batch_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DeliveryMapScreen extends StatefulWidget {
  final Batch batch;
  const DeliveryMapScreen({super.key, required this.batch});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  final ApiService _apiService = ApiService();
  final MapController _mapController = MapController(); // Ajout du contrôleur
  List<LatLng> _firstSegment = [];
  List<LatLng> _otherSegments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOptimizedRoute();
  }

  Future<void> _loadOptimizedRoute() async {
    setState(() => _isLoading = true);
    try {
      Location courierPos = Location(
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

      setState(() {
        _firstSegment = segments['first'] ?? [];
        _otherSegments = segments['others'] ?? [];
        _isLoading = false;
      });

      // AJUSTEMENT AUTOMATIQUE DU ZOOM (Sécurisé)
      _fitRoute();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur d'itinéraire: $e")));
      }
    }
  }

  void _fitRoute() {
    final allPoints = [..._firstSegment, ..._otherSegments];

    // On ne calcule les bounds QUE si on a des points
    if (allPoints.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(allPoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50.0)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tournée : ${widget.batch.id}"),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController, // Liaison du contrôleur
        options: const MapOptions(
          initialCenter: LatLng(14.7000, -17.4500),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.yobulma.app',
          ),

          // TRACÉ DES RUES
          PolylineLayer(
            polylines: [
              if (_firstSegment.isNotEmpty)
                Polyline(
                  points: _firstSegment,
                  color: Colors.black,
                  strokeWidth: 5.0,
                  pattern: StrokePattern.dashed(segments: [6, 6]),
                ),
              if (_otherSegments.isNotEmpty)
                Polyline(
                  points: _otherSegments,
                  color: Colors.blue.withOpacity(0.8),
                  strokeWidth: 5.0,
                ),
            ],
          ),

          // MARQUEURS
          MarkerLayer(
            markers: [
              // Marqueur Livreur (Optionnel mais recommandé)
              Marker(
                point: const LatLng(14.6928, -17.4467),
                child: const Icon(
                  Icons.directions_bike,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              // Marqueurs Livraisons
              ...widget.batch.deliveries.map((order) {
                return Marker(
                  point: LatLng(
                    order.deliveryLocation.latitude!,
                    order.deliveryLocation.longitude!,
                  ),
                  width: 60,
                  height: 60,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30,
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(blurRadius: 2, color: Colors.black26),
                          ],
                        ),
                        child: Text(
                          order.clientName.split(' ')[0],
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _loadOptimizedRoute,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
