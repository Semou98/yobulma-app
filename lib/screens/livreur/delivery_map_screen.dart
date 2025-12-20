import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/batch_model.dart';

class DeliveryMapScreen extends StatelessWidget {
  final Batch batch;
  const DeliveryMapScreen({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigation Itinéraire"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(14.6937, -17.4441), // Dakar
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          // Ici on pourrait rajouter la Polyline si on passait les points,
          // mais restons simple : affichons juste les points de livraison.
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(14.6937, -17.4441),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
