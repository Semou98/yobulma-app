import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String defaultUrlAndroidEmulator = 'http://10.0.2.2:8000';
  static const String defaultUrlWeb = 'http://localhost:8000';

  Future<String> _getUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_url') ?? defaultUrlWeb;
  }

  // 1. Appel à l'API pour récupérer le trajet Dijkstra
  Future<Map<String, dynamic>> getOptimalRoute(List<String> orderIds) async {
    final baseUrl = await _getUrl();
    final response = await http.post(
      Uri.parse('$baseUrl/delivery-tour'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'order_ids': orderIds}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur API');
    }
  }

  // 2. Extraction des points pour tracer la ligne orange sur la carte
  List<LatLng> extractPolylinePoints(Map<String, dynamic> apiResponse) {
    List<LatLng> points = [];
    if (apiResponse['steps'] != null) {
      for (var step in apiResponse['steps']) {
        var coords = step['route_geojson']['coordinates'];
        for (var c in coords) {
          // GeoJSON est [Lon, Lat], Leaflet veut [Lat, Lon]
          points.add(LatLng(c[1], c[0]));
        }
      }
    }
    return points;
  }
}
