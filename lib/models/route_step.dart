class RouteStep {
  final String deliveryId;
  final double distanceMeters;
  final List<List<double>>
  polylineCoordinates; // Coordonnées extraites du GeoJSON

  RouteStep({
    required this.deliveryId,
    required this.distanceMeters,
    required this.polylineCoordinates,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    // Extraction des coordonnées du format GeoJSON LineString
    var coords = json['route_geojson']['coordinates'] as List;
    List<List<double>> parsedCoords = coords
        .map(
          (c) => [
            (c[1] as num).toDouble(), // Latitude
            (c[0] as num).toDouble(), // Longitude (GeoJSON est [lon, lat])
          ],
        )
        .toList();

    return RouteStep(
      deliveryId: json['delivery_id'].toString(),
      distanceMeters: (json['distance_m'] as num).toDouble(),
      polylineCoordinates: parsedCoords,
    );
  }
}
