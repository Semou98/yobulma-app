import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  bool _loading = true;
  String _distance = "0";

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  void _loadItinerary() async {
    print("--- DÉBUT CHARGEMENT ITINÉRAIRE ---");
    print("Appel API pour les commandes: ${widget.batch.orderIds}");

    try {
      final data = await _apiService.getOptimalRoute(widget.batch.orderIds);

      // LOG 1: Voir le JSON brut reçu
      print("JSON REÇU DE L'API: $data");

      // LOG 2: Vérifier la structure attendue
      if (data['steps'] == null) {
        print("ATTENTION: La clé 'steps' est absente du JSON");
      } else {
        print("Nombre d'étapes (steps) trouvées: ${data['steps'].length}");
      }

      setState(() {
        _points = _apiService.extractPolylinePoints(data);

        // LOG 3: Vérifier les points extraits
        print("Nombre de points GPS extraits pour la carte: ${_points.length}");

        double distMeters = 0;
        if (data['steps'] != null && data['steps'].isNotEmpty) {
          distMeters = data['steps'][0]['distance_m']?.toDouble() ?? 0;
        }

        _distance = (distMeters / 1000).toStringAsFixed(1);
        _loading = false;
      });

      print("--- CHARGEMENT RÉUSSI ---");
    } catch (e, stacktrace) {
      // LOG 4: L'erreur détaillée
      print("ERREUR API DÉTECTÉE: $e");
      print("DÉTAILS TECHNIQUES: $stacktrace");

      setState(() {
        _points = [LatLng(14.699, -17.450), LatLng(14.715, -17.467)];
        _distance = "3.3 (DÉMO)";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lot : ${widget.batch.quartier}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
              ),
              if (_points.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _points,
                      color: const Color(0xFFFF9800),
                      strokeWidth: 5,
                    ),
                  ],
                ),
            ],
          ),
          // Overlay Infos
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.straighten, color: Color(0xFFFF9800)),
                title: Text("Distance estimée : $_distance km"),
                subtitle: Text("${widget.batch.orderCount} colis à livrer"),
              ),
            ),
          ),
          // Bouton d'acceptation
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.all(15),
              ),
              onPressed: () {
                // TODO: Naviguer vers l'écran de livraison active (Étape 3)
                _showSuccess();
              },
              child: const Text(
                "ACCEPTER LA TOURNÉE",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9800)),
            ),
        ],
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Lot accepté ! Tournée démarrée."),
        backgroundColor: Colors.green,
      ),
    );

    // Remplacer l'écran actuel par l'écran de livraison active
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveDeliveryScreen(batch: widget.batch),
      ),
    );
  }
}
