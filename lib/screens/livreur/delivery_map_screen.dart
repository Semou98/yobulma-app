import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yoboulma_app/models/location_model.dart';
import 'package:yoboulma_app/services/api_service.dart';
import '../../models/batch_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'active_delivery_screen.dart'; // L'écran vers lequel on redirige

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
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _loadOptimizedRoute();
  }

  Future<void> _loadOptimizedRoute() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Position fictive du livreur (Dakar)
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur d'itinéraire: $e")));
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

  Future<void> _acceptBatch() async {
    setState(() => _isAccepting = true);

    try {
      // Simulation de l'appel API pour accepter le batch
      // await _apiService.acceptBatch(widget.batch.id);
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Redirection vers l'écran de livraison active (on remplace la page actuelle)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveDeliveryScreen(batch: widget.batch),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAccepting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : Impossible d'accepter le batch")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Itinéraire : ${widget.batch.id.substring(0, 8)}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // CARTE
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(14.7000, -17.4500),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yobulma.app',
              ),
              PolylineLayer(
                polylines: [
                  if (_firstSegment.isNotEmpty)
                    Polyline(
                      points: _firstSegment,
                      color: Colors.black,
                      strokeWidth: 4.5,
                      pattern: StrokePattern.dashed(segments: [8, 5]),
                    ),
                  if (_otherSegments.isNotEmpty)
                    Polyline(
                      points: _otherSegments,
                      color: Colors.blue.shade700,
                      strokeWidth: 4.5,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Position du Livreur
                  Marker(
                    point: const LatLng(14.6928, -17.4467),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.directions_bike,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  // Points de livraisons
                  ...widget.batch.deliveries.map((delivery) {
                    return Marker(
                      point: LatLng(
                        delivery.deliveryLocation.latitude!,
                        delivery.deliveryLocation.longitude!,
                      ),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // CHARGEMENT
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // BARRE D'ACTION BAS DE PAGE
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomPanel()),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.batch.deliveries.length} livraisons",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const Text(
                      "Gain estimé",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  "${widget.batch.deliveryFee.toInt()} FCFA",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_isLoading || _isAccepting) ? null : _acceptBatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: _isAccepting
                    ? const SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "ACCEPTER ET COMMENCER",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
