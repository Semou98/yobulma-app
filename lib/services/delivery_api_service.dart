// lib/services/delivery_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeliveryApiService {
  static const String baseUrl = 'https://delevery-api-mgd9.onrender.com';
  
  // Méthode pour optimiser la route avec plusieurs points
  Future<Map<String, dynamic>> optimizeRoute(List<Map<String, dynamic>> points) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/optimize-route'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'points': points}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to optimize route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error optimizing route: $e');
      rethrow;
    }
  }
  
  // Méthode pour calculer la distance entre deux points
  Future<double> calculateDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calculate-distance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'start': {'latitude': startLat, 'longitude': startLng},
          'end': {'latitude': endLat, 'longitude': endLng},
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['distance'];
      } else {
        throw Exception('Failed to calculate distance');
      }
    } catch (e) {
      print('Error calculating distance: $e');
      rethrow;
    }
  }
  
  // Méthode pour estimer le prix de livraison
  Future<double> estimateDeliveryPrice({
    required double distance,
    required String quartier,
    double? orderAmount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/estimate-price'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'distance': distance,
          'quartier': quartier,
          'order_amount': orderAmount,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['estimated_price'];
      } else {
        // Retourner un prix par défaut si l'API échoue
        return _getDefaultPrice(distance, quartier);
      }
    } catch (e) {
      print('Error estimating price: $e');
      return _getDefaultPrice(distance, quartier);
    }
  }
  
  double _getDefaultPrice(double distance, String quartier) {
    // Prix par défaut basé sur la distance
    if (distance < 5) return 1000;
    if (distance < 10) return 1500;
    if (distance < 15) return 2000;
    return 2500;
  }
}