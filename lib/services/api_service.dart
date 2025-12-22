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
  try {
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

    print("Envoi de la requête à l'API...");
    final response = await http.post(
      Uri.parse('$apiBaseUrl/delivery-tour'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print("Statut de la réponse: ${response.statusCode}");
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Réponse API réussie, structure des données:");
      print(data.keys.toList()); // Affiche les clés disponibles
      return data;
    } else {
      print("Erreur API (${response.statusCode}): ${response.body}");
      // Retourne un format par défaut pour éviter les erreurs
      return {
        'steps': [],
        'distance': 0,
        'duration': 0
      };
    }
  } catch (e) {
    print("Exception lors de l'appel API: $e");
    // Retourne un format par défaut en cas d'erreur
    return {
      'steps': [],
      'distance': 0,
      'duration': 0
    };
  }
}

  // Extraction des segments pour la carte - Version robuste
  Map<String, List<LatLng>> extractRouteSegments(
    Map<String, dynamic> apiResponse,
  ) {
    final List<LatLng> firstSegment = [];
    final List<LatLng> others = [];

    try {
      print("Extraction des segments de la réponse API...");
      print("Clés disponibles: ${apiResponse.keys.toList()}");

      // Vérifie si 'steps' existe et est une liste
      if (apiResponse['steps'] != null && apiResponse['steps'] is List) {
        final steps = apiResponse['steps'] as List;
        print("Nombre de steps trouvées: ${steps.length}");

        for (int i = 0; i < steps.length; i++) {
          final step = steps[i];
          
          // Essaye plusieurs façons d'extraire les coordonnées
          List<dynamic>? coordinates;
          
          // Essai 1: route_geojson.coordinates
          if (step is Map && 
              step['route_geojson'] is Map && 
              step['route_geojson']['coordinates'] is List) {
            coordinates = step['route_geojson']['coordinates'] as List;
          }
          // Essai 2: coordinates directement dans le step
          else if (step is Map && step['coordinates'] is List) {
            coordinates = step['coordinates'] as List;
          }
          // Essai 3: geometry.coordinates (format GeoJSON standard)
          else if (step is Map && 
                   step['geometry'] is Map && 
                   step['geometry']['coordinates'] is List) {
            coordinates = step['geometry']['coordinates'] as List;
          }

          if (coordinates != null) {
            print("Step $i: ${coordinates.length} coordonnées trouvées");
            
            // Conversion des coordonnées en LatLng
            final List<LatLng> points = coordinates.map((coord) {
              // Supporte à la fois [lon, lat] et [lat, lon]
              if (coord is List && coord.length >= 2) {
                // On essaie de deviner le format en vérifiant les valeurs
                final double first = (coord[0] as num).toDouble();
                final double second = (coord[1] as num).toDouble();
                
                // Les coordonnées de Dakar sont ~14.7 lat, -17.5 lon
                // Si la première valeur est négative, c'est probablement la longitude
                if (first < 0) {
                  return LatLng(second, first); // [lon, lat]
                } else {
                  return LatLng(first, second); // [lat, lon]
                }
              }
              return LatLng(0, 0);
            }).toList();

            if (i == 0) {
              firstSegment.addAll(points);
            } else {
              others.addAll(points);
            }
          } else {
            print("Step $i: Pas de coordonnées trouvées");
          }
        }
      } else {
        print("Aucune step trouvée dans la réponse");
      }

      print("Premier segment: ${firstSegment.length} points");
      print("Autres segments: ${others.length} points");

    } catch (e) {
      print("Erreur lors de l'extraction des segments: $e");
    }

    // Points par défaut si extraction échoue
    if (firstSegment.isEmpty) {
      firstSegment.addAll([
        LatLng(14.699, -17.450),
        LatLng(14.705, -17.455),
        LatLng(14.710, -17.460),
        LatLng(14.715, -17.467)
      ]);
    }

    return {'first': firstSegment, 'others': others};
  }

  // Ajout de la méthode extractPolylinePoints pour compatibilité
  List<LatLng> extractPolylinePoints(Map<String, dynamic> apiResponse) {
    final segments = extractRouteSegments(apiResponse);
    final allPoints = <LatLng>[];
    allPoints.addAll(segments['first'] ?? []);
    allPoints.addAll(segments['others'] ?? []);
    return allPoints;
  }
}