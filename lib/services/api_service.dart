import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/order_model.dart';
import '../models/location_model.dart';

class ApiService {
  static const String apiBaseUrl = 'https://delevery-api-mgd9.onrender.com';

  Future<Map<String, dynamic>> getOptimalRoute(
    Location courierPos,
    List<Order> orders,
  ) async {
    // 1. Préparation du body selon le schéma Pydantic de l'API
    final Map<String, dynamic> requestBody = {
      "courier": {"lat": courierPos.latitude, "lon": courierPos.longitude},
      "deliveries": orders.map((order) {
        final String numericId = order.id.replaceAll(RegExp(r'[^0-9]'), '');
        final int idAsInt = int.tryParse(numericId) ?? 0;
        return {
          "id": idAsInt, // L'API recevra un entier
          "lat": order.deliveryLocation.latitude,
          "lon": order.deliveryLocation.longitude,
        };
      }).toList(),
    };

    final response = await http.post(
      Uri.parse('$apiBaseUrl/delivery-tour'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Erreur API: ${response.body}");
      throw Exception('Erreur lors du calcul de l\'itinéraire');
    }
  }

  // Extraction des segments pour la carte
  Map<String, List<LatLng>> extractRouteSegments(
    Map<String, dynamic> apiResponse,
  ) {
    List<LatLng> firstSegment = [];
    List<LatLng> others = [];

    if (apiResponse['steps'] != null) {
      final steps = apiResponse['steps'] as List;

      for (int i = 0; i < steps.length; i++) {
        var coords = steps[i]['route_geojson']['coordinates'] as List;
        // Conversion GeoJSON [lon, lat] -> LatLng(lat, lon)
        List<LatLng> points = coords.map((c) => LatLng(c[1], c[0])).toList();

        if (i == 0) {
          firstSegment.addAll(points);
        } else {
          // On ajoute les points aux segments restants
          others.addAll(points);
        }
      }
    }
    return {'first': firstSegment, 'others': others};
  }
}
